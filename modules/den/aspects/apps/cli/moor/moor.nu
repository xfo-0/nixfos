def manifest-path [] {
  let xdg = ($env.XDG_CONFIG_HOME? | default ($env.HOME | path join ".config"))
  $env.MOOR_MANIFEST? | default (
    [($xdg | path join "moor/manifest.nuon"), ($xdg | path join "moor/manifest.json")]
    | where {|p| $p | path exists }
    | get 0? | default ($xdg | path join "moor/manifest.nuon")
  )
}

def projects-dir [] {
  if ($env.XDG_PROJECTS_DIR? | is-not-empty) {
    return $env.XDG_PROJECTS_DIR
  }
  let r = (do { xdg-user-dir PROJECTS } | complete)
  if $r.exit_code == 0 {
    let d = ($r.stdout | str trim)
    if ($d | is-not-empty) and $d != $env.HOME {
      return $d
    }
  }
  $env.HOME | path join "Projects"
}

def manifest-load [] {
  let main = (if ((manifest-path) | path exists) { open (manifest-path) } else { {} })
  let merged = (($main.include? | default [])
    | where {|p| $p | path exists }
    | reduce -f $main {|p, acc|
        let m = (open $p)
        $acc
        | upsert roots ((($acc.roots? | default []) ++ ($m.roots? | default [])) | uniq)
        | upsert groups (($acc.groups? | default {}) | merge ($m.groups? | default {}))
        | upsert repos (($acc.repos? | default []) ++ ($m.repos? | default []))
      })
  if (($merged.roots? | default []) | is-empty) {
    $merged | upsert roots [(projects-dir)]
  } else {
    $merged
  }
}

def cache-db [] {
  ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache")) | path join "moor.db"
}

def normalize-url [raw: string] {
  $raw
  | str trim
  | str replace -r '\.git$' ''
  | str replace -r '^(git\+)?(https?|ssh)://' ''
  | str replace -r '^git@([^:/]+)[:/]' '$1/'
}

def url-parts [url: string] {
  let segs = ($url | split row "/")
  {
    host: ($segs.0? | default "")
    owner: ($segs.1? | default "")
    name: ($segs | last)
  }
}

def pin-map [] {
  let m = (manifest-load)
  let lockp = ($m.pins_lock? | default "")
  if ($lockp | is-empty) or (not ($lockp | path exists)) {
    return []
  }
  let raw = (open $lockp)
  let lock = (if (($raw | describe) == "string") { $raw | from json } else { $raw })
  let entries = (if ($lock.nodes? | describe | str starts-with "record") {
    let root = ($lock.root? | default "root")
    $lock.nodes
    | transpose input meta
    | where {|r| $r.input != $root and (($r.meta.locked? | describe) | str starts-with "record") }
    | each {|r| { input: $r.input, meta: $r.meta.locked } }
  } else {
    $lock | transpose input meta
  })
  $entries
  | where {|r| ($r.meta | describe | str starts-with "record") and ($r.meta.rev? | is-not-empty) }
  | each {|r|
      let url = (if ($r.meta.type? in ["github", "gitlab", "sourcehut"]) {
        let host = ($r.meta.host? | default (match $r.meta.type? {
          "gitlab" => "gitlab.com"
          "sourcehut" => "git.sr.ht"
          _ => "github.com"
        }))
        $"($host)/($r.meta.owner)/($r.meta.repo)"
      } else if ($r.meta.url? | is-not-empty) {
        normalize-url $r.meta.url
      } else {
        ""
      })
      { url: $url, input: $r.input, rev: $r.meta.rev, nar_hash: ($r.meta.narHash? | default "") }
    }
  | where url != ""
}

def repo-origin [p: string] {
  let g = (do { git -C $p config --get remote.origin.url } | complete)
  if $g.exit_code == 0 {
    $g.stdout
  } else {
    let j = (do { jj -R $p git remote list } | complete)
    if $j.exit_code == 0 {
      $j.stdout | lines | parse "{name} {url}" | where name == "origin" | get url | get 0? | default ""
    } else {
      ""
    }
  }
}

def gh-cache-path [] {
  ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache")) | path join "moor-gh.nuon"
}

def gh-cache [] {
  let p = (gh-cache-path)
  if ($p | path exists) { open $p } else { { starred: [], lists: [] } }
}

# overview of moor subcommands
export def main [] {
  scope commands | where name =~ '^moor ' | select name description
}

def gh-list-items [id: string] {
  mut items = []
  mut cursor = ""
  loop {
    let after = (if ($cursor | is-empty) { "" } else { ', after: "' + $cursor + '"' })
    let q = ('{ node(id: "' + $id + '") { ... on UserList { items(first: 100' + $after + ') { nodes { ... on Repository { nameWithOwner } } pageInfo { hasNextPage endCursor } } } } }')
    let r = (do { gh api graphql -f ("query=" + $q) } | complete)
    if $r.exit_code != 0 { break }
    let d = ($r.stdout | from json | get data.node.items)
    $items = ($items ++ ($d.nodes | each {|n| $"github.com/($n.nameWithOwner)" }))
    if not $d.pageInfo.hasNextPage { break }
    $cursor = $d.pageInfo.endCursor
  }
  $items
}

# sync GitHub starred repos and lists into local cache (used by `moor scan`)
export def "moor gh-sync" [] {
  let starred = (gh api user/starred --paginate --jq ".[].full_name" | lines | each {|s| $"github.com/($s)" })
  let res = (do { gh api graphql -f query="{ viewer { lists(first: 100) { nodes { id name } } } }" } | complete)
  let lists = (if $res.exit_code == 0 {
    $res.stdout | from json | get data.viewer.lists.nodes | each {|l|
      { name: $l.name, repos: (gh-list-items $l.id) }
    }
  } else {
    []
  })
  { starred: $starred, lists: $lists } | save -f (gh-cache-path)
  print $"gh-sync: ($starred | length) starred, ($lists | length) lists \(($lists | get repos | flatten | length) repos\) -> (gh-cache-path)"
}

def repo-dirty [p: string, vcs: string] {
  if $vcs == "jj" {
    let r = (do { jj -R $p --ignore-working-copy log -r "@" --no-graph -T 'if(empty, "clean", "dirty")' } | complete)
    if $r.exit_code == 0 and ($r.stdout | str contains "dirty") { 1 } else { 0 }
  } else {
    let r = (do { git -C $p status --porcelain } | complete)
    if $r.exit_code == 0 and ($r.stdout | str trim | is-not-empty) { 1 } else { 0 }
  }
}

def pin-behind [p: string, vcs: string, rev: string] {
  if $vcs == "jj" {
    let r = (do { jj -R $p --ignore-working-copy log -r ($rev + "..trunk()") --no-graph -T '"1\n"' } | complete)
    if $r.exit_code == 0 { $r.stdout | lines | length } else { -1 }
  } else {
    let r = (do { git -C $p rev-list --count $"($rev)..origin/HEAD" } | complete)
    if $r.exit_code == 0 { $r.stdout | str trim | into int } else { -1 }
  }
}

def rev-exists [p: string, rev: string] {
  if ($p | path join ".git" | path exists) {
    (do { git -C $p cat-file -e ($rev + "^{commit}") } | complete | get exit_code) == 0
  } else {
    (do { jj -R $p --ignore-working-copy log -r $rev --no-graph -T '""' } | complete | get exit_code) == 0
  }
}

def repo-ref [p: string, vcs: string] {
  if $vcs == "jj" {
    let r = (do { jj -R $p --ignore-working-copy log -r "latest(::@ & bookmarks())" --no-graph -T "bookmarks" } | complete)
    if $r.exit_code == 0 {
      $r.stdout | str trim | split row " " | get 0? | default "" | str replace -r '[*?]+$' ""
    } else {
      ""
    }
  } else {
    let r = (do { git -C $p branch --show-current } | complete)
    if $r.exit_code == 0 { $r.stdout | str trim } else { "" }
  }
}

def scan-one [p: string, curated: list, pins: list, gh: record] {
  let raw = (repo-origin $p)
  let url = (if ($raw | is-empty) { "" } else { normalize-url $raw })
  let parts = (url-parts $url)
  let cur = ($curated | where {|c| $c.url == $url or ($url in ($c.aliases? | default [])) })
  let ids = (if ($cur | is-empty) { [$url] } else { [$cur.0.url] ++ ($cur.0.aliases? | default []) })
  let matched = ($pins | where {|pn| $pn.url in $ids })
  let tk = (do { tokei $p --output json } | complete)
  let langs = (if $tk.exit_code == 0 {
    $tk.stdout
    | from json
    | transpose lang stats
    | where lang != "Total"
    | sort-by -r {|r| $r.stats.code }
    | first 3
    | get lang
    | str join ","
  } else {
    ""
  })
  let vcs = (if ($p | path join ".jj" | path exists) { "jj" } else { "git" })
  let ws = (if $vcs == "jj" {
    if (($p | path join ".jj/repo" | path type) == "file") { 1 } else { 0 }
  } else {
    if (($p | path join ".git" | path type) == "file") { 1 } else { 0 }
  })
  let pin_rows = ($matched | each {|pn|
      let local = (rev-exists $p $pn.rev)
      {
        path: $p
        input: $pn.input
        url: $pn.url
        rev: $pn.rev
        nar_hash: $pn.nar_hash
        local: (if $local { 1 } else { 0 })
        behind: (if $local { pin-behind $p $vcs $pn.rev } else { -1 })
      }
    })
  {
    repo: {
      path: $p
      url: $url
      host: $parts.host
      owner: $parts.owner
      name: $parts.name
      vcs: $vcs
      ws: $ws
      ref: (repo-ref $p $vcs)
      flake: (if ($p | path join "flake.nix" | path exists) { 1 } else { 0 })
      langs: $langs
      dirty: (repo-dirty $p $vcs)
      tags: (if ($cur | is-empty) { "" } else { $cur.0.tags | str join "," })
      note: (if ($cur | is-empty) { "" } else { $cur.0.note? | default "" })
      private: (if ($cur | is-empty) { 0 } else { if ($cur.0.private? | default false) { 1 } else { 0 } })
      starred: (if ($url in $gh.starred) { 1 } else { 0 })
      gh_lists: ($gh.lists | where {|l| $url in $l.repos } | get name | str join ",")
    }
    pins: $pin_rows
  }
}

# scan manifest roots for git/jj repos and rebuild the cache db
export def "moor scan" [] {
  let m = (manifest-load)
  let curated = ($m.repos? | default [])
  let pins = (pin-map)
  let dirs = ($m.roots
    | each {|root| fd -H --no-ignore -t d -t f -d 8 '^\.(jj|git)$' $root | lines | each {|l| $l | path dirname } }
    | flatten
    | uniq
    | sort
    | reduce -f [] {|d, acc|
        if (($acc | is-not-empty) and ($d | str starts-with (($acc | last) + "/"))) { $acc } else { $acc ++ [$d] }
      })
  let gh = (gh-cache)
  let results = ($dirs | par-each {|p| scan-one $p $curated $pins $gh })
  let rows = ($results | get repo | sort-by path)
  let pin_rows = ($results | get pins | flatten)
  let db = (cache-db)
  rm -f $db
  $rows | into sqlite $db -t repos_base
  if ($pin_rows | is-not-empty) {
    $pin_rows | into sqlite $db -t pins
  } else {
    open $db | query db "create table pins (path text, input text, url text, rev text, nar_hash text, local int, behind int)" | ignore
  }
  open $db | query db "
    create view repos as
    select b.*,
      coalesce(g.pin_input, '') as pin_input,
      coalesce(g.pin_url, '') as pin_url,
      coalesce(g.pin_rev, '') as pin_rev,
      coalesce(g.pin_local, 0) as pin_local,
      coalesce(g.pin_behind, -1) as pin_behind
    from repos_base b
    left join (
      select path,
        group_concat(input, ',') as pin_input,
        group_concat(distinct url) as pin_url,
        group_concat(rev, ',') as pin_rev,
        min(local) as pin_local,
        max(behind) as pin_behind
      from pins group by path
    ) g on b.path = g.path
  " | ignore
  print $"scanned ($rows | length) repos, ($pin_rows | length) pins -> ($db)"
}

# fuzzy-pick a repo (optionally from a group) and cd into it
export def --env mcd [group?: string] {
  let rows = (if ($group | is-empty) { moor ls } else { moor ls $group })
  let sel = ($rows | get path | to text | tv | str trim)
  if ($sel | is-not-empty) {
    cd $sel
  }
}

# list cached repos, filtered by manifest group or raw sql via --where
export def "moor ls" [group?: string, --where (-w): string] {
  let db = (cache-db)
  if not ($db | path exists) {
    error make { msg: "no cache, run `moor scan` first" }
  }
  let cond = (if ($where | is-not-empty) {
    $where
  } else if ($group | is-not-empty) {
    manifest-load | get groups | get $group
  } else {
    "1=1"
  })
  open $db | query db $"select * from repos where ($cond)"
}

# verify pinned revs against lock narHash; seed the nix store from local clones
# so locked inputs resolve offline without remote fetches (--check: verify only)
export def "moor pin-seed" [--check] {
  let db = (cache-db)
  if not ($db | path exists) {
    error make { msg: "no cache, run `moor scan` first" }
  }
  let rows = (open $db
    | query db "select p.path, p.input, p.rev, p.nar_hash, b.name from pins p join repos_base b on p.path = b.path where p.local = 1 order by p.input")
  $rows | each {|r|
    let status = (if ($r.nar_hash | is-empty) {
      "no-narhash"
    } else {
      let tmp = (mktemp -d)
      let tar = ($tmp | path join "src.tar")
      let out = ($tmp | path join "source")
      mkdir $out
      let gd = (if (($r.path | path join ".git") | path exists) {
        $r.path | path join ".git"
      } else {
        $r.path | path join ".jj/repo/store/git"
      })
      let ar = (do { git --git-dir $gd archive -o $tar $r.rev } | complete)
      let status = (if $ar.exit_code != 0 {
        $"archive-failed: ($ar.stderr | str trim)"
      } else {
        ^tar -xf $tar -C $out
        let h = (nix hash path $out | str trim)
        if $h != $r.nar_hash {
          $"mismatch: local ($h)"
        } else if $check {
          "verified"
        } else {
          let add = (do { nix store add --name source $out } | complete)
          if $add.exit_code == 0 {
            $"seeded: ($add.stdout | str trim)"
          } else {
            $"add-failed: ($add.stderr | str trim)"
          }
        }
      })
      rm -rf $tmp
      $status
    })
    { input: $r.input, name: $r.name, rev: ($r.rev | str substring 0..7), status: $status }
  }
}

# list pin rows: one per flake input matched to a local clone
export def "moor pins" [] {
  let db = (cache-db)
  if not ($db | path exists) {
    error make { msg: "no cache, run `moor scan` first" }
  }
  open $db | query db "select p.input, b.name, p.rev, p.local, p.behind, p.path from pins p join repos_base b on p.path = b.path order by p.input"
}

# show manifest groups (name -> sql predicate)
export def "moor groups" [] {
  manifest-load | get groups
}

def ws-backing [p: string, vcs: string] {
  if $vcs == "jj" {
    let raw = (open ($p | path join ".jj/repo") | str trim)
    if ($raw | str starts-with "/") { $raw } else { $p | path join ".jj" $raw | path expand -n }
  } else {
    let raw = (open ($p | path join ".git") | str trim | str replace -r '^gitdir: ' '')
    if ($raw | str starts-with "/") { $raw } else { $p | path join $raw | path expand -n }
  }
}

def resolve-repo [q: string] {
  let db = (cache-db)
  if not ($db | path exists) {
    error make { msg: "no cache, run `moor scan` first" }
  }
  let rows = (open $db | query db $"select * from repos_base where ws = 0 and \(name = '($q)' or url like '%($q)%' or path like '%($q)%'\)")
  if ($rows | length) == 1 {
    $rows.0
  } else if ($rows | is-empty) {
    error make { msg: $"no repo matches ($q)" }
  } else {
    error make { msg: $"ambiguous ($q): ($rows | get path | str join ', ')" }
  }
}

# add a jj workspace for a repo at <root>/<host>/<owner>/<name>@<ws-name>
export def "moor ws add" [query: string, name: string] {
  let r = (resolve-repo $query)
  if $r.vcs != "jj" {
    error make { msg: $"($r.path) is not jj-managed; git worktrees not supported yet" }
  }
  let root = (manifest-load | get roots | get 0)
  let dest = ($root | path join ($r.url + "@" + $name))
  if ($dest | path exists) {
    error make { msg: $"($dest) already exists" }
  }
  mkdir ($dest | path dirname)
  jj -R $r.path workspace add --name $name $dest
  print $"workspace ($name): ($dest)  re-run `moor scan`"
}

# forget a jj workspace and delete its directory; refuses if it has changes
export def "moor ws rm" [path: string] {
  let p = ($path | path expand)
  let repof = ($p | path join ".jj/repo")
  if (($repof | path type) != "file") {
    error make { msg: $"($p) is not a jj workspace" }
  }
  let st = (do { jj -R $p log -r "@" --no-graph -T 'if(empty, "clean", "dirty")' } | complete)
  if ($st.stdout | str contains "dirty") {
    error make { msg: $"($p) has uncommitted changes; commit or abandon first" }
  }
  let primary = (ws-backing $p "jj" | path dirname | path dirname)
  let name = ($p | path basename | split row "@" | last)
  jj -R $primary workspace forget $name
  rm -rf $p
  print $"removed workspace ($name) at ($p)  re-run `moor scan`"
}

# report layout drift and missing pin remotes; canonical path is
# <root>/<host>/<owner>/<name>, workspaces/worktrees get @<ref> suffix
export def "moor doctor" [--add-remotes, --fix-layout] {
  let m = (manifest-load)
  let root = ($m.roots | get 0)
  let issues = (moor ls | each {|r|
    let orphan = (if $r.ws == 1 {
      let target = (ws-backing $r.path $r.vcs)
      if ($target | path exists) { [] } else {
        [{ path: $r.path, issue: "ws-orphaned", fix: $"# backing repo missing: ($target); files salvageable as plain tree" }]
      }
    } else {
      []
    })
    let layout = (if ($orphan | is-not-empty) {
      []
    } else if ($r.url | is-empty) {
      [{ path: $r.path, issue: "no-origin", fix: "" }]
    } else {
      let base = ($root | path join $r.url)
      let expected = (if $r.ws == 1 {
        if ($r.path | str starts-with ($base + "@")) {
          $r.path
        } else if ($r.ref | is-empty) {
          ""
        } else {
          $base + "@" + ($r.ref | str replace -a "/" "-")
        }
      } else {
        $base
      })
      if ($expected | is-empty) or $r.path == $expected { [] } else if ($expected | path exists) {
        [{ path: $r.path, issue: "layout-collision", fix: $"# ($expected) already exists" }]
      } else {
        [{ path: $r.path, issue: "layout", fix: $"mkdir -p '($expected | path dirname)' && mv '($r.path)' '($expected)'" }]
      }
    })
    $orphan ++ $layout
  } | flatten)
  let remotes = (open (cache-db)
    | query db "select p.path, p.url as pin_url, b.url, b.vcs from pins p join repos_base b on p.path = b.path where p.local = 0 and p.url != '' and p.url != b.url"
    | each {|r|
        let owner = ($r.pin_url | split row "/" | get 1)
        let cmd = (if $r.vcs == "jj" {
          $"jj -R ($r.path) git remote add ($owner) https://($r.pin_url)"
        } else {
          $"git -C ($r.path) remote add ($owner) https://($r.pin_url)"
        })
        { path: $r.path, issue: "pin-remote-missing", fix: $cmd }
      })
  let issues = ($issues ++ $remotes)
  if $add_remotes {
    $issues | where issue == "pin-remote-missing" | each {|i|
      print $"applying: ($i.fix)"
      do { sh -c $i.fix } | complete | ignore
    }
    print "remotes added; re-run `moor scan` then `moor pin-sync`"
  }
  if $fix_layout {
    $issues | where issue == "layout" | each {|i|
      print $"applying: ($i.fix)"
      let res = (do { sh -c $i.fix } | complete)
      if $res.exit_code != 0 {
        print $"  failed: ($res.stderr | str trim)"
      }
    }
    print "layout fixed; re-run `moor scan`"
  }
  print ($issues | group-by issue | transpose issue count | update count {|r| $r.count | length })
  $issues
}

# fetch flake-pinned revs where missing and mark them as cfg-pin bookmark/tag
export def "moor pin-sync" [] {
  let rows = (open (cache-db)
    | query db "select p.path, p.input, p.rev, b.vcs, b.name, (select count(*) from pins q where q.path = p.path) as npins from pins p join repos_base b on p.path = b.path order by p.input")
  $rows | each {|r|
    let had = (rev-exists $r.path $r.rev)
    if not $had {
      if $r.vcs == "jj" {
        do { jj -R $r.path git fetch --all-remotes } | complete | ignore
      } else {
        do { git -C $r.path fetch --all --quiet } | complete | ignore
      }
    }
    let ok = (rev-exists $r.path $r.rev)
    let ok = (if $ok {
      true
    } else if ($r.path | path join ".git" | path exists) {
      git -C $r.path remote | lines | each {|rm|
        do { git -C $r.path fetch $rm $r.rev } | complete | ignore
      }
      rev-exists $r.path $r.rev
    } else {
      false
    })
    let mark = (if $r.npins > 1 { $"cfg-pin-($r.input)" } else { "cfg-pin" })
    let status = (if not $ok {
      "rev-unavailable"
    } else if $r.vcs == "jj" {
      let res = (do { jj -R $r.path --ignore-working-copy bookmark set $mark -r $r.rev --allow-backwards } | complete)
      if $res.exit_code == 0 {
        "bookmarked"
      } else if ($r.path | path join ".git" | path exists) {
        let ref = (do { git -C $r.path update-ref $"refs/heads/($mark)" $r.rev } | complete)
        if $ref.exit_code == 0 { "bookmarked (git-ref)" } else { $"error: ($res.stderr | str trim)" }
      } else {
        $"error: ($res.stderr | str trim)"
      }
    } else {
      let res = (do { git -C $r.path tag -f $mark $r.rev } | complete)
      if $res.exit_code == 0 { "tagged" } else { $"error: ($res.stderr | str trim)" }
    })
    {
      input: $r.input
      name: $r.name
      path: $r.path
      rev: ($r.rev | str substring 0..7)
      fetched: (not $had)
      status: $status
    }
  }
}

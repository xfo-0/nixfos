const MANIFEST_DEFAULT = "/etc/nixos/repos.nuon"

def manifest-path [] {
  $env.REPOS_MANIFEST? | default $MANIFEST_DEFAULT
}

def cache-db [] {
  ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache")) | path join "repos.db"
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
  let m = (open (manifest-path))
  let lockp = ($m.pins_lock? | default "/etc/nixos/.tack/pins.lock.json")
  if not ($lockp | path exists) {
    return []
  }
  open $lockp
  | transpose input meta
  | where {|r| ($r.meta | describe | str starts-with "record") and ($r.meta.rev? | is-not-empty) }
  | each {|r|
      let url = (if ($r.meta.type? == "github") {
        $"github.com/($r.meta.owner)/($r.meta.repo)"
      } else if ($r.meta.url? | is-not-empty) {
        normalize-url $r.meta.url
      } else {
        ""
      })
      { url: $url, input: $r.input, rev: $r.meta.rev }
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
  ($env.XDG_CACHE_HOME? | default ($env.HOME | path join ".cache")) | path join "repos-gh.nuon"
}

def gh-cache [] {
  let p = (gh-cache-path)
  if ($p | path exists) { open $p } else { { starred: [], lists: [] } }
}

export def "repo gh-sync" [] {
  let starred = (gh api user/starred --paginate --jq ".[].full_name" | lines | each {|s| $"github.com/($s)" })
  let res = (do { gh api graphql -f query="{ viewer { lists(first: 50) { nodes { name items(first: 100) { nodes { ... on Repository { nameWithOwner } } } } } } }" } | complete)
  let lists = (if $res.exit_code == 0 {
    $res.stdout | from json | get data.viewer.lists.nodes | each {|l|
      { name: $l.name, repos: ($l.items.nodes | each {|n| $"github.com/($n.nameWithOwner)" }) }
    }
  } else {
    []
  })
  { starred: $starred, lists: $lists } | save -f (gh-cache-path)
  print $"gh-sync: ($starred | length) starred, ($lists | length) lists -> (gh-cache-path)"
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

def pin-behind [p: string, vcs: string] {
  if $vcs == "jj" {
    let r = (do { jj -R $p --ignore-working-copy log -r "cfg-pin..trunk()" --no-graph -T '"1\n"' } | complete)
    if $r.exit_code == 0 { $r.stdout | lines | length } else { -1 }
  } else {
    let r = (do { git -C $p rev-list --count "cfg-pin..origin/HEAD" } | complete)
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

def scan-one [p: string, curated: list, pins: list, gh: record] {
  let raw = (repo-origin $p)
  let url = (if ($raw | is-empty) { "" } else { normalize-url $raw })
  let parts = (url-parts $url)
  let cur = ($curated | where {|c| $c.url == $url or ($url in ($c.aliases? | default [])) })
  let ids = (if ($cur | is-empty) { [$url] } else { [$cur.0.url] ++ ($cur.0.aliases? | default []) })
  let pin = ($pins | where {|pn| $pn.url in $ids })
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
  let pin_rev = (if ($pin | is-empty) { "" } else { $pin.0.rev })
  let vcs = (if ($p | path join ".jj" | path exists) { "jj" } else { "git" })
  {
    path: $p
    url: $url
    host: $parts.host
    owner: $parts.owner
    name: $parts.name
    vcs: $vcs
    flake: (if ($p | path join "flake.nix" | path exists) { 1 } else { 0 })
    langs: $langs
    dirty: (repo-dirty $p $vcs)
    tags: (if ($cur | is-empty) { "" } else { $cur.0.tags | str join "," })
    note: (if ($cur | is-empty) { "" } else { $cur.0.note? | default "" })
    pin_input: (if ($pin | is-empty) { "" } else { $pin.0.input })
    pin_url: (if ($pin | is-empty) { "" } else { $pin.0.url })
    pin_rev: $pin_rev
    pin_local: (if ($pin_rev == "") { 0 } else { if (rev-exists $p $pin_rev) { 1 } else { 0 } })
    pin_behind: (if ($pin_rev == "") { -1 } else { pin-behind $p $vcs })
    starred: (if ($url in $gh.starred) { 1 } else { 0 })
    gh_lists: ($gh.lists | where {|l| $url in $l.repos } | get name | str join ",")
  }
}

export def "repo scan" [] {
  let m = (open (manifest-path))
  let curated = ($m.repos? | default [])
  let pins = (pin-map)
  let dirs = ($m.roots
    | each {|root| fd -H --no-ignore -t d -d 8 '^\.(jj|git)$' $root | lines | each {|l| $l | path dirname } }
    | flatten
    | uniq
    | sort
    | reduce -f [] {|d, acc|
        if (($acc | is-not-empty) and ($d | str starts-with (($acc | last) + "/"))) { $acc } else { $acc ++ [$d] }
      })
  let gh = (gh-cache)
  let rows = ($dirs | par-each {|p| scan-one $p $curated $pins $gh } | sort-by path)
  let db = (cache-db)
  rm -f $db
  $rows | into sqlite $db -t repos
  if (which zoxide | is-not-empty) {
    zoxide add ...($rows | get path)
  }
  print $"scanned ($rows | length) repos -> ($db)"
}

export def --env rcd [group?: string] {
  let rows = (if ($group | is-empty) { repo ls } else { repo ls $group })
  let sel = ($rows | get path | to text | tv | str trim)
  if ($sel | is-not-empty) {
    cd $sel
  }
}

export def "repo ls" [group?: string, --where (-w): string] {
  let db = (cache-db)
  if not ($db | path exists) {
    error make { msg: "no cache, run `repo scan` first" }
  }
  let cond = (if ($where | is-not-empty) {
    $where
  } else if ($group | is-not-empty) {
    open (manifest-path) | get groups | get $group
  } else {
    "1=1"
  })
  open $db | query db $"select * from repos where ($cond)"
}

export def "repo groups" [] {
  open (manifest-path) | get groups
}

export def "repo doctor" [--add-remotes] {
  let m = (open (manifest-path))
  let root = ($m.roots | get 0)
  let issues = (repo ls | each {|r|
    let layout = (if ($r.url | is-empty) {
      [{ path: $r.path, issue: "no-origin", fix: "" }]
    } else {
      let expected = ($root | path join $r.url)
      if $r.path == $expected { [] } else {
        [{ path: $r.path, issue: "layout", fix: $"mv ($r.path) ($expected)" }]
      }
    })
    let remote = (if ($r.pin_rev != "" and $r.pin_local == 0 and ($r.pin_url | is-not-empty) and $r.pin_url != $r.url) {
      let owner = ($r.pin_url | split row "/" | get 1)
      let cmd = (if $r.vcs == "jj" {
        $"jj -R ($r.path) git remote add ($owner) https://($r.pin_url)"
      } else {
        $"git -C ($r.path) remote add ($owner) https://($r.pin_url)"
      })
      [{ path: $r.path, issue: "pin-remote-missing", fix: $cmd }]
    } else {
      []
    })
    $layout ++ $remote
  } | flatten)
  if $add_remotes {
    $issues | where issue == "pin-remote-missing" | each {|i|
      print $"applying: ($i.fix)"
      do { sh -c $i.fix } | complete | ignore
    }
    print "remotes added; re-run `repo scan` then `repo pin-sync`"
  }
  print ($issues | group-by issue | transpose issue count | update count {|r| $r.count | length })
  $issues
}

export def "repo pin-sync" [] {
  let rows = (repo ls --where "pin_rev != ''")
  $rows | each {|r|
    let had = (rev-exists $r.path $r.pin_rev)
    if not $had {
      if $r.vcs == "jj" {
        do { jj -R $r.path git fetch --all-remotes } | complete | ignore
      } else {
        do { git -C $r.path fetch --all --quiet } | complete | ignore
      }
    }
    let ok = (rev-exists $r.path $r.pin_rev)
    let ok = (if $ok {
      true
    } else if ($r.path | path join ".git" | path exists) {
      git -C $r.path remote | lines | each {|rm|
        do { git -C $r.path fetch $rm $r.pin_rev } | complete | ignore
      }
      rev-exists $r.path $r.pin_rev
    } else {
      false
    })
    let status = (if not $ok {
      "rev-unavailable"
    } else if $r.vcs == "jj" {
      let res = (do { jj -R $r.path --ignore-working-copy bookmark set cfg-pin -r $r.pin_rev --allow-backwards } | complete)
      if $res.exit_code == 0 {
        "bookmarked"
      } else if ($r.path | path join ".git" | path exists) {
        let ref = (do { git -C $r.path update-ref refs/heads/cfg-pin $r.pin_rev } | complete)
        if $ref.exit_code == 0 { "bookmarked (git-ref)" } else { $"error: ($res.stderr | str trim)" }
      } else {
        $"error: ($res.stderr | str trim)"
      }
    } else {
      let res = (do { git -C $r.path tag -f cfg-pin $r.pin_rev } | complete)
      if $res.exit_code == 0 { "tagged" } else { $"error: ($res.stderr | str trim)" }
    })
    {
      input: $r.pin_input
      name: $r.name
      path: $r.path
      rev: ($r.pin_rev | str substring 0..7)
      fetched: (not $had)
      status: $status
    }
  }
}

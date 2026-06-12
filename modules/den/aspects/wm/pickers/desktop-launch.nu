
let pick = "term-pick"

let dirs = ($env.XDG_DATA_DIRS?
  | default ""
  | split row ":"
  | where { is-not-empty }
  | each {|d| $"($d)/applications" }
  | prepend $"($env.HOME)/.local/share/applications"
  | uniq)

let entries = ($dirs
  | where { path exists }
  | each {|d| glob $"($d)/*.desktop" }
  | flatten
  | each {|f|
    let lines = (open $f --raw | lines
      | take while {|l| not ($l | str starts-with "[Desktop Action") or $l == "[Desktop Entry]" }
      | where {|l| $l =~ "=" })
    let kv = ($lines | reduce -f {} {|l, acc|
      let idx = ($l | str index-of "=")
      let key = ($l | str substring 0..<$idx | str trim)
      let value = ($l | str substring ($idx + 1).. | str trim)
      $acc | merge { $key: $value }
    })
    let name = ($kv | get -o Name | default "")
    let exec_raw = ($kv | get -o Exec | default "")
    let nodisplay = ($kv | get -o NoDisplay | default "false")
    let exec_cmd = ($exec_raw | str replace -ra ' %[fFuUdDnNickvm]' '')
    if $nodisplay != "true" and ($name | is-not-empty) and ($exec_cmd | is-not-empty) {
      { name: $name, exec: $exec_cmd }
    }
  }
  | compact
  | uniq-by name
  | sort-by name -i)

if ($entries | is-empty) { exit }

let names = ($entries | each {|r| $r.name } | str join "\n")
let selected = try { $names | ^$pick } catch { exit }

$selected | split row "\n" | where {|l| $l | is-not-empty } | each {|name|
  let exec_cmd = ($entries | where name == $name | first | get exec)
  niri msg action spawn -- sh -c $exec_cmd
}

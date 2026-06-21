
let pick = "term-pick"

let ws_map = (niri msg -j workspaces | from json
  | reduce -f {} {|w, acc| $acc | merge {($w.id | into string): $w.idx}})

let windows = (niri msg -j windows | from json
  | where app_id != "term_picker" and is_focused != true
  | each {|w|
    let idx = ($ws_map | get -o ($w.workspace_id | into string) | default "?")
    {id: $w.id, display: $"($idx) ($w.app_id)\t($w.title)"}
  })

if ($windows | is-empty) { exit }

let display = ($windows | each {|w| $w.display } | str join "\n")
let selected = try { $display | ^$pick } catch { exit }
let line = ($selected | split row "\n" | first)
let wid = ($windows | where display == $line | first | get id)

niri msg action focus-window --id $wid

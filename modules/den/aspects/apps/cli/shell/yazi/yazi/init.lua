-- session (not available in nixpkgs yaziPlugins)
-- require("session"):setup({
--   sync_yanked = true,
-- })

-- starship
require("starship"):setup({
  config_file = "~/.config/starship.toml",
})

require("git"):setup()

-- custom: move tabs back to header
function Tabs.height() return 0 end

Header:children_add(function()
  if #cx.tabs == 1 then return "" end
  local spans = {}
  for i = 1, #cx.tabs do
    spans[#spans + 1] = ui.Span(" " .. i .. " ")
  end
  spans[cx.tabs.idx]:reverse()
  return ui.Line(spans)
end, 9000, Header.RIGHT)

-- custom: some padding
local old_layout = Tab.layout

Tab.layout = function(self, ...)
  self._area = ui.Rect({ x = self._area.x, y = self._area.y + 1, w = self._area.w, h = self._area.h - 2 })
  return old_layout(self, ...)
end

local function shorten_nix_path(target, current_file)
  if not target then return target end

  local target_str = tostring(target)
  local cwd = tostring(cx.active.current.cwd)

  -- Extract current_path once and reuse
  local current_path = current_file and tostring(current_file.url):gsub("^file://", "")

  -- Handle /etc/static paths (early return pattern)
  if cwd:sub(1, 4) == "/etc" then
    local static_path = target_str:match("^/etc/static/(.+)$")
    if static_path then
      if current_path and current_path:sub(1, 5) == "/etc/" then
        local relative_current = current_path:sub(6)
        if static_path == relative_current then return "󱄅 static" end
      end
      return "󱄅 static/" .. static_path
    end
  end

  -- Parse Nix store paths
  local package_and_path = target_str:match("^/nix/store/[a-z0-9]+%-(.+)$")
  if not package_and_path then return target_str end

  -- Handle home-manager paths
  local inner_path = package_and_path:match("^home%-manager%-files/(.+)$")
  if inner_path then
    local home = os.getenv("HOME")
    if home and cwd:sub(1, #home) == home and current_path then
      if current_path:sub(1, #home + 1) == home .. "/" then
        local relative_current = current_path:sub(#home + 2)
        if inner_path == relative_current then return "󱄅 hm" end
      end
      return "󱄅 hm/" .. inner_path
    end
  end

  -- Handle other Nix packages
  local abbreviated_rest = package_and_path:gsub("^system%-config%-", "sys-")

  -- Check for filename match
  if current_file and abbreviated_rest == current_file.name then return "󱄅" end

  return "󱄅 " .. abbreviated_rest
end

-- Override Entity:symlink() to use shortened Nix store paths
function Entity:symlink()
  if not rt.mgr.show_symlink then return "" end

  local to = self._file.link_to
  if not to then return "" end

  local shortened_target = shorten_nix_path(to, self._file)
  return ui.Span(string.format(" → %s", shortened_target)):style(th.mgr.symlink_target)
end

function Linemode:size_and_mtime()
  local time = math.floor(self._file.cha.mtime or 0)
  if time == 0 then
    time = ""
  elseif os.date("%Y", time) == os.date("%Y") then
    time = os.date("%b %d %H:%M", time)
  else
    time = os.date("%b %d  %Y", time)
  end

  local size = self._file:size()
  return string.format("%s %s", size and ya.readable_size(size) or "-", time)
end

function Status:name()
  local h = self._tab.current.hovered
  if not h then return ui.Line({}) end

  -- Return empty line to hide the hovered file name
  return ui.Line({})
end

-- show user group next to permissions
Status:children_add(function()
  local h = cx.active.current.hovered
  if not h then return "" end
  local user = h.cha.uid and ya.user_name(h.cha.uid) or h.cha.uid
  local group = h and h.cha.gid and ya.user_name(h.cha.gid) or h.cha.gid
  return ui.Line({
    ui.Span(string.format(" %s", user)):fg("yellow"),
    ui.Span(":"),
    ui.Span(string.format("%s ", group)):fg("yellow"),
  })
end, 1, Status.RIGHT)

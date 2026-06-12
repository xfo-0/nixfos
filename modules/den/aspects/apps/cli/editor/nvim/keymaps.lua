local map = vim.keymap.set
local m = { "n", "v", "s", "o" }

-- ── Colemak: mModes (n,v,s,o) ──────────────────────────────────────

map(m, "S", "D", { desc = "Delete to end of line" })
map(m, "<Home>", "gg", { desc = "Go to first line" })
map(m, "<End>", "G", { desc = "Go to last line" })
map(m, "C", "B", { desc = "Move back WORD" })
map(m, "c", "b", { desc = "Move back word" })
map(m, "i", "e", { desc = "Move to end of word" })
map(m, "I", "E", { desc = "Move to end of WORD" })

-- ── Colemak: Normal mode ────────────────────────────────────────────

map("n", "<Del>", "c", { desc = "Change" })
map("n", "s", "d", { desc = "Delete" })
map("n", "b", "v", { desc = "Start char-wise visual" })
map("n", "k", "V", { desc = "Start line-wise visual" })
map("n", "<BS>", "<C-V>", { desc = "Start block-wise visual" })

map({ "n", "x" }, "e", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down" })
map({ "n", "x" }, "n", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up" })

map("n", "N", "<C-O>", { desc = "Previous jump" })
map("n", "E", "<C-I>", { desc = "Next jump" })
map("n", "x", "i", { desc = "Insert before cursor" })
map("n", "X", "I", { desc = "Insert at line start" })
map("n", "z", "a", { nowait = true, desc = "Append after cursor" })
map("n", "Z", "A", { desc = "Append at line end" })
map("n", "<C-t>", "O", { desc = "Open line above" })
map("n", "<C-a>", "o", { desc = "Open line below" })
map("n", "<C-Home>", "O<Esc>j", { desc = "Add blank line above" })
map("n", "<C-End>", "o<Esc>k", { desc = "Add blank line below" })
map("n", "-", "u", { desc = "Undo" })
map("n", "+", "<cmd>redo<CR>", { desc = "Redo" })

-- ── Colemak: Visual mode ────────────────────────────────────────────

map("v", "<Left>", "h", { desc = "Move left" })
map("v", "<Right>", "l", { desc = "Move right" })
map("v", "N", "<C-O>", { desc = "Previous jump" })
map("v", "E", "<C-I>", { desc = "Next jump" })
map("v", "q", "<Esc>", { desc = "Exit visual mode" })
map("v", "<Del>", "c", { desc = "Change selection" })
map("v", "s", "d", { desc = "Delete selection" })
map("v", "b", "v", { desc = "Toggle char-wise visual" })
map("v", "k", "V", { desc = "Switch to line-wise visual" })
map("v", "<BS>", "<C-V>", { desc = "Switch to block-wise visual" })
map("v", "g", "r", { desc = "Replace with char" })

map("v", 'z"', 'a"', { desc = "Around double quotes" })
map("v", "z'", "a'", { desc = "Around single quotes" })
map("v", "z<", "a<", { desc = "Around angle brackets" })
map("v", "z[", "a[", { desc = "Around square brackets" })
map("v", "z`", "a`", { desc = "Around backticks" })
map("v", "zp", "ap", { desc = "Around paragraph" })
map("v", "zs", "as", { desc = "Around sentence" })
map("v", "zt", "at", { desc = "Around tag" })
map("v", "zv", "aw", { desc = "Around word" })

map("v", 'x"', 'i"', { desc = "Inside double quotes" })
map("v", "x<", "i<", { desc = "Inside angle brackets" })
map("v", "x[", "i[", { desc = "Inside square brackets" })
map("v", "x`", "i`", { desc = "Inside backticks" })
map("v", "xp", "ip", { desc = "Inside paragraph" })
map("v", "xs", "is", { desc = "Inside sentence" })
map("v", "xt", "it", { desc = "Inside tag" })

-- ── Colemak: Operator-pending mode ──────────────────────────────────

map("o", "x", "i", { desc = "Inside" })
map("o", "z", "a", { desc = "Around" })
map("o", "b", "v", { desc = "Force char-wise" })
map("o", "k", "V", { desc = "Force line-wise" })
map("o", "<BS>", "<C-V>", { desc = "Force block-wise" })

-- ── Colemak: Visual-block (x) mode ─────────────────────────────────

map("x", "X", "I", { desc = "Insert at selection start" })
map("x", "Z", "A", { desc = "Append at selection end" })

-- ── Move lines ──────────────────────────────────────────────────────

map("n", "<C-e>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<C-n>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<C-e>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<C-n>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<C-e>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<C-n>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- ── Undo breakpoints in insert ──────────────────────────────────────

map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- ── Save ────────────────────────────────────────────────────────────

map({ "i", "x", "n", "s" }, "<C-=>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- ── Search (direction-aware) ────────────────────────────────────────

map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd("noh")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

map("n", "<C-i>", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map({ "x", "o" }, "<C-i>", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "<C-c>", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map({ "x", "o" }, "<C-c>", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- ── Better indenting ────────────────────────────────────────────────

map("x", "<", "<gv")
map("x", ">", ">gv")

-- ── Commenting (add comment above/below) ────────────────────────────

map("n", "ace", "o<esc>Vcx<esc><cmd>normal acc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "acn", "O<esc>Vcx<esc><cmd>normal acc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- ── Windows ─────────────────────────────────────────────────────────

map("n", "<leader>-", "<C-W>s", { remap = true, desc = "Split Window Below" })
map("n", "<leader>|", "<C-W>v", { remap = true, desc = "Split Window Right" })
map("n", "<leader>wd", "<C-W>c", { remap = true, desc = "Delete Window" })

-- ── Tabs ────────────────────────────────────────────────────────────

map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- ── Quit ────────────────────────────────────────────────────────────

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- ── LSP format ──────────────────────────────────────────────────────

map({ "n", "x" }, "<leader>cf", function()
  vim.lsp.buf.format({ async = false })
end, { desc = "Format" })

map({ "n", "x" }, "<leader>cF", function()
  require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
end, { desc = "Format Injected Langs" })

-- ── Diagnostics ─────────────────────────────────────────────────────

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", function() vim.diagnostic.jump({ count = vim.v.count1, float = true }) end, { desc = "Next Diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -vim.v.count1, float = true }) end, { desc = "Prev Diagnostic" })
map("n", "]e", function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end, { desc = "Next Error" })
map("n", "[e", function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.ERROR, float = true }) end, { desc = "Prev Error" })
map("n", "]w", function() vim.diagnostic.jump({ count = vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end, { desc = "Next Warning" })
map("n", "[w", function() vim.diagnostic.jump({ count = -vim.v.count1, severity = vim.diagnostic.severity.WARN, float = true }) end, { desc = "Prev Warning" })

-- ── Trouble ─────────────────────────────────────────────────────────

map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
map("n", "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer Diagnostics (Trouble)" })
map("n", "<leader>xL", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
map("n", "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
map("n", "<leader>xt", "<cmd>Trouble todo toggle<cr>", { desc = "Todo (Trouble)" })
map("n", "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", { desc = "Todo/Fix/Fixme (Trouble)" })

map("n", "<leader>xq", function()
  local ok, err = pcall(function()
    local qf = vim.fn.getqflist({ winid = 0 })
    if qf.winid ~= 0 then vim.cmd.cclose() else vim.cmd.copen() end
  end)
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Quickfix List" })

map("n", "<leader>xl", function()
  local ok, err = pcall(function()
    local loc = vim.fn.getloclist(0, { winid = 0 })
    if loc.winid ~= 0 then vim.cmd.lclose() else vim.cmd.lopen() end
  end)
  if not ok and err then vim.notify(err, vim.log.levels.ERROR) end
end, { desc = "Location List" })

map("n", "[q", function()
  local ok, trouble = pcall(require, "trouble")
  if ok and trouble.is_open() then
    trouble.prev({ skip_groups = true, jump = true })
  else
    pcall(vim.cmd.cprev)
  end
end, { desc = "Previous Trouble/Quickfix Item" })

map("n", "]q", function()
  local ok, trouble = pcall(require, "trouble")
  if ok and trouble.is_open() then
    trouble.next({ skip_groups = true, jump = true })
  else
    pcall(vim.cmd.cnext)
  end
end, { desc = "Next Trouble/Quickfix Item" })

-- ── Misc ────────────────────────────────────────────────────────────

map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function()
  vim.treesitter.inspect_tree()
  vim.api.nvim_input("I")
end, { desc = "Inspect Tree" })

-- ── Lazygit (floating terminal) ─────────────────────────────────────

map("n", "<leader>gg", function()
  local buf = vim.api.nvim_create_buf(false, true)
  local w = math.floor(vim.o.columns * 0.9)
  local h = math.floor(vim.o.lines * 0.9)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w, height = h,
    row = math.floor((vim.o.lines - h) / 2),
    col = math.floor((vim.o.columns - w) / 2),
    style = "minimal",
    border = "single",
  })
  vim.fn.termopen("lazygit", {
    on_exit = function()
      pcall(vim.api.nvim_win_close, win, true)
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end,
  })
  vim.cmd("startinsert")
end, { desc = "Lazygit" })

-- ── Plugin keymaps (require pcall in case plugin not loaded) ────────

-- yanky.nvim
map({ "n", "x" }, "h", "<Plug>(YankyYank)", { desc = "Yank" })
map({ "n", "x" }, "H", function()
  vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>(YankyYank)$", true, true, true), "m")
end, { desc = "Yank to end of line" })
map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Put after" })
map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Put before" })
map("n", "<C-p>", "<Plug>(YankyPreviousEntry)", { desc = "Cycle yank ring back" })
map("n", "<C-l>", "<Plug>(YankyNextEntry)", { desc = "Cycle yank ring forward" })

-- yazi.nvim
map("n", "<C-Space>", function()
  local ok, yazi = pcall(require, "yazi")
  if ok then yazi.yazi() end
end, { desc = "Open Yazi" })

-- grug-far.nvim
map({ "n", "x" }, "<leader>sr", function()
  local ok, grug = pcall(require, "grug-far")
  if not ok then return end
  local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  grug.open({
    transient = true,
    prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
  })
end, { desc = "Search and Replace" })

-- which-key
map("n", "<leader>?", function()
  local ok, wk = pcall(require, "which-key")
  if ok then wk.show({ global = false }) end
end, { desc = "Buffer Keymaps" })
map("n", "<leader>wk", function()
  local ok, wk = pcall(require, "which-key")
  if ok then wk.show() end
end, { desc = "Which Key (global)" })

-- ── Treesitter textobjects (move) ───────────────────────────────────

vim.api.nvim_create_autocmd("User", {
  pattern = "TSUpdate",
  once = true,
  callback = function() end,
})

do
  local ok, move = pcall(require, "nvim-treesitter-textobjects.move")
  if ok then
    local opts = { silent = true }
    local function tmap(lhs, fn, desc)
      map({ "n", "x", "o" }, lhs, fn, vim.tbl_extend("force", opts, { desc = desc }))
    end
    tmap("]f", function() move.goto_next_start("@function.outer") end, "Next function start")
    tmap("]F", function() move.goto_next_end("@function.outer") end, "Next function end")
    tmap("]c", function() move.goto_next_start("@class.outer") end, "Next class start")
    tmap("]C", function() move.goto_next_end("@class.outer") end, "Next class end")
    tmap("]a", function() move.goto_next_start("@parameter.inner") end, "Next parameter")
    tmap("]A", function() move.goto_next_end("@parameter.inner") end, "Next parameter end")
    tmap("[f", function() move.goto_previous_start("@function.outer") end, "Prev function start")
    tmap("[F", function() move.goto_previous_end("@function.outer") end, "Prev function end")
    tmap("[c", function() move.goto_previous_start("@class.outer") end, "Prev class start")
    tmap("[C", function() move.goto_previous_end("@class.outer") end, "Prev class end")
    tmap("[a", function() move.goto_previous_start("@parameter.inner") end, "Prev parameter")
    tmap("[A", function() move.goto_previous_end("@parameter.inner") end, "Prev parameter end")
  end
end

-- ── Gitsigns per-buffer keymaps via autocmd ─────────────────────────

vim.api.nvim_create_autocmd("User", {
  pattern = "GitSignsAttach",
  callback = function(args)
    local gs = require("gitsigns")
    local buffer = args.buf
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc, silent = true })
    end
    bmap("n", "]h", function()
      if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
    end, "Next Hunk")
    bmap("n", "[h", function()
      if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
    end, "Prev Hunk")
    bmap("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
    bmap("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
    bmap({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
    bmap({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
    bmap("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
    bmap("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
    bmap("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
    bmap("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
    bmap("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
    bmap("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
    bmap("n", "<leader>ghd", gs.diffthis, "Diff This")
    bmap("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
    bmap({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
  end,
})

-- ── which-key groups ────────────────────────────────────────────────

do
  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add({
      { "<leader>c", group = "Coding" },
      { "<leader>f", group = "Find/File" },
      { "<leader>g", group = "Git" },
      { "<leader>gh", group = "Hunks" },
      { "<leader>s", group = "Search" },
      { "<leader>u", group = "UI" },
      { "<leader>w", group = "Workspace" },
      { "<leader>x", group = "Diagnostics/Trouble" },
      { "<leader><tab>", group = "Tabs" },

      { "s", desc = "Delete", mode = "n" },
      { "h", desc = "Yank", mode = "n" },
      { "<Del>", desc = "Change", mode = "n" },
      { "ac", group = "Comment", mode = { "n", "o", "x" } },

      { "z", group = "Around", mode = { "o", "x" } },
      { "x", group = "Inside", mode = { "o", "x" } },
      { "zn", group = "Around next", mode = { "o", "x" } },
      { "xn", group = "Inside next", mode = { "o", "x" } },
      { "zl", group = "Around last", mode = { "o", "x" } },
      { "xl", group = "Inside last", mode = { "o", "x" } },
    })
  end
end

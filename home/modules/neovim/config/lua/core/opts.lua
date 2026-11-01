local opt = vim.opt
local config = require("core.cfg")

vim.g.theme_cache = vim.fn.stdpath("data") .. "/colors_data/"
vim.g.statusStyle = config.statusstyle
vim.g.loaded_python3_provider = 0
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.termguicolors = true
opt.number = true
opt.relativenumber = true
opt.numberwidth = 3
opt.signcolumn = "yes:1"
opt.cursorline = true
opt.showmode = false
opt.ruler = false
opt.laststatus = 3
opt.showtabline = 0
opt.cmdheight = 0
opt.pumheight = 10
opt.completeopt = { "menu", "menuone", "noselect" }
opt.updatetime = 250
opt.timeoutlen = 400
opt.clipboard = "unnamedplus"
opt.mouse = "a"
opt.mousescroll = "ver:0,hor:0"
opt.hidden = true
opt.confirm = true
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.inccommand = "split"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"
opt.wrap = false
opt.breakindent = true
opt.conceallevel = 0
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true
opt.list = false
opt.fillchars:append({ eob = " " })
opt.shortmess:append("sI")
opt.swapfile = false
opt.backup = false
opt.writebackup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(vim.o.undodir, "p", 448)
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.lazyredraw = false

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  underline = true,
  virtual_text = { spacing = 2, prefix = "●", severity = { min = vim.diagnostic.severity.WARN } },
  float = { border = "rounded", source = "if_many" },
  signs = { text = { [1] = "●", [2] = "▲", [3] = "●", [4] = "·" } },
})

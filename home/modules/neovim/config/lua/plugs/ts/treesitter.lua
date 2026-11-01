local ts = require("nvim-treesitter")
ts.setup({})
vim.filetype.add({ extension = { mdx = "mdx", lean = "lean" } })
vim.treesitter.language.register("markdown", "mdx")
local group = vim.api.nvim_create_augroup("UserTreesitter", { clear = true })
local function start(buf)
  if vim.bo[buf].buftype ~= "" or require("core.largefile").is_large(buf) then
    return
  end
  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  if not lang or not pcall(vim.treesitter.start, buf, lang) then
    return
  end
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  vim.wo.foldmethod = "expr"
  vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
end
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function(args)
    start(args.buf)
  end,
})
vim.api.nvim_create_autocmd("User", {
  group = group,
  pattern = "TSUpdate",
  callback = function()
    start(vim.api.nvim_get_current_buf())
  end,
})
-- Parser installation is explicit: opening files never downloads tools.
-- Use :TSInstall <language> or :TSUpdate; Nix supplies tree-sitter-cli.

local M = {}

-- Transparent segment highlights inherit StatusLine, not Normal. Set the
-- base explicitly so Neovim's default gray cannot show through them.
function M.apply()
  local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
  local muted = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  vim.api.nvim_set_hl(0, "StatusLine", { fg = normal.fg, bg = normal.bg or "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineNC", { fg = muted.fg or normal.fg, bg = normal.bg or "NONE" })
end

local group = vim.api.nvim_create_augroup("UserStatuslineColors", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = M.apply })
M.apply()
-- Prism reloads custom modules before writing the new palette.
vim.schedule(M.apply)
return M

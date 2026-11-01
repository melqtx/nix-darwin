local group = vim.api.nvim_create_augroup("UserInterface", { clear = true })
local pending = false
local function refresh()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    require("ui.buf").setup()
    vim.cmd("redrawstatus")
  end)
end
require("ui.stl").setup(vim.g.statusStyle)
require("ui.buf").setup()
vim.api.nvim_create_autocmd(
  { "BufAdd", "BufDelete", "BufEnter", "BufFilePost", "DiagnosticChanged", "LspAttach", "LspDetach" },
  {
    group = group,
    callback = refresh,
  }
)

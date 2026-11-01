local ok, err = xpcall(function()
  require("lazy").update({ wait = true, show = false })
  for name, plugin in pairs(require("lazy.core.config").plugins) do
    for _, task in ipairs(plugin._.tasks or {}) do
      assert(not task:has_errors(), "Plugin update failed: " .. name)
    end
  end
  assert(vim.v.errmsg == "", vim.v.errmsg)
end, debug.traceback)
if not ok then
  print(err)
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end

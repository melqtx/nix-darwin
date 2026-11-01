local ok, err = xpcall(function()
  local parsers = vim.json.decode(table.concat(vim.fn.readfile(vim.env.DOTS_NVIM_PARSERS), "\n"))
  require("nvim-treesitter").install(parsers):wait(300000)
  require("nvim-treesitter").update(parsers):wait(300000)
  assert(vim.o.mousescroll == "ver:0,hor:0", "Wheel scrolling must remain disabled")
end, debug.traceback)
if not ok then
  print(err)
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end

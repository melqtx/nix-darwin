local ok, err = xpcall(function()
  assert(vim.v.errmsg == "", vim.v.errmsg)
  local parsers = vim.json.decode(table.concat(vim.fn.readfile(vim.env.DOTS_NVIM_PARSERS), "\n"))
  for _, lang in ipairs(parsers) do
    vim.treesitter.language.add(lang)
    assert(vim.treesitter.query.get(lang, "highlights"), "Missing highlights for " .. lang)
  end
  assert(vim.o.mousescroll == "ver:0,hor:0", "Wheel scrolling must remain disabled")
  print("Verified pinned parsers, highlight queries, startup, and disabled scrolling")
end, debug.traceback)
if not ok then
  print(err)
  vim.cmd("cquit 1")
else
  vim.cmd("qa!")
end

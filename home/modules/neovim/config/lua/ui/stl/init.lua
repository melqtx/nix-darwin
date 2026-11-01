local M = {}
function M.run(style)
  return table.concat({
    require("ui.stl.modules.mode")(style),
    require("ui.stl.modules.filename")(style),
    require("ui.stl.modules.branch")(),
    require("ui.stl.modules.diff")(style),
    "%=",
    require("ui.stl.modules.diagnostics")(style),
    require("ui.stl.modules.folder")(style),
    require("ui.stl.modules.lsp")(style) or "",
    require("ui.stl.modules.position")(style),
  })
end
function M.render()
  return M.run(vim.g.statusStyle or "minimal")
end
function M.setup(style)
  vim.g.statusStyle = style or "minimal"
  vim.o.laststatus = 3
  vim.o.statusline = '%!v:lua.require("ui.stl").render()'
end
return M

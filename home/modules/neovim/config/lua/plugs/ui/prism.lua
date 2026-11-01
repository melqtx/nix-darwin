local cfg = require("core.cfg")

-- Resolve modules directly; Prism treats the config directory as a Lua pattern.
require("prism.themer").loadLocalTb = function(_, group)
  return require("hls." .. group)
end

require("prism"):setup({
  customSchemes = cfg.customSchemes,
  currentTheme = "fovere",
  reset = vim.fn.filereadable(vim.fn.stdpath("data") .. "/prism/allThemes") == 0,
  customFiles = vim.fn.stdpath("config") .. "/lua/hls",
  transparent = true,
  reload = { "ui.stl.highlights" },
})

require("ui.stl.highlights").apply()

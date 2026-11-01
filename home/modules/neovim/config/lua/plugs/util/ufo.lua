local ufo = require("ufo")

ufo.setup({
  provider_selector = function()
    return { "treesitter", "indent" }
  end,
})

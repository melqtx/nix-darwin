local conform = require("conform")
conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "nixfmt" },
    rust = { "rustfmt" },
    zig = { "zigfmt" },
    go = { "gofumpt" },
    python = { "ruff_format" },
    haskell = { "fourmolu" },
    java = { "google-java-format" },
    javascript = { "prettier" },
    javascriptreact = { "prettier" },
    typescript = { "prettier" },
    typescriptreact = { "prettier" },
    json = { "prettier" },
    jsonc = { "prettier" },
    yaml = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    markdown = { "prettier" },
    mdx = { "prettier" },
  },
  default_format_opts = { lsp_format = "fallback" },
  format_on_save = function(buf)
    if
      vim.g.disable_autoformat
      or vim.b[buf].disable_autoformat
      or vim.bo[buf].buftype ~= ""
      or require("core.largefile").is_large(buf)
    then
      return
    end
    return { timeout_ms = 2000, lsp_format = "fallback" }
  end,
})
vim.api.nvim_create_user_command("Format", function()
  conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "Format the current buffer" })
vim.api.nvim_create_user_command("FormatToggle", function()
  vim.b.disable_autoformat = not vim.b.disable_autoformat
  vim.notify("Format on save: " .. (vim.b.disable_autoformat and "off" or "on"))
end, { desc = "Toggle format on save for this buffer" })
vim.keymap.set("n", "<leader>lf", "<Cmd>Format<CR>", { desc = "Format file", silent = true })
vim.keymap.set("n", "<leader>uf", "<Cmd>FormatToggle<CR>", { desc = "Toggle format on save", silent = true })

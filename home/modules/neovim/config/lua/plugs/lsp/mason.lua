local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_tool_installer = require("mason-tool-installer")

local servers = {
  "ansiblels",
  "astro",
  "bashls",
  "clangd",
  "cssls",
  "docker_compose_language_service",
  "dockerls",
  "emmet_ls",
  "gopls",
  "helm_ls",
  "html",
  "jsonls",
  "lua_ls",
  "marksman",
  "nixd",
  "pyright",
  "ruff",
  "terraformls",
  "vue_ls",
  "yamlls",
}

local npm_servers = {
  ansiblels = true,
  astro = true,
  bashls = true,
  cssls = true,
  docker_compose_language_service = true,
  dockerls = true,
  emmet_ls = true,
  html = true,
  jsonls = true,
  pyright = true,
  vue_ls = true,
  yamlls = true,
}

local function installable_servers()
  if vim.fn.executable("npm") == 1 then
    return servers
  end

  return vim.tbl_filter(function(server)
    return not npm_servers[server]
  end, servers)
end

mason.setup({
  ui = {
    icons = {
      package_pending = " ",
      package_installed = " ",
      package_uninstalled = "󰚌",
    },

    keymaps = {
      toggle_server_expand = "<CR>",
      install_server = "i",
      update_server = "u",
      check_server_version = "c",
      update_all_servers = "U",
      check_outdated_servers = "C",
      uninstall_server = "X",
      cancel_installation = "<C-c>",
    },
  },

  max_concurrent_installers = 10,
})

mason_lspconfig.setup({
  ensure_installed = installable_servers(),
  automatic_enable = true,
})

mason_tool_installer.setup({
  ensure_installed = {
    "ansible-lint",
    "black",
    "hadolint",
    "isort",
    "ruff",
    "shellcheck",
    "shfmt",
  },
  run_on_start = true,
})

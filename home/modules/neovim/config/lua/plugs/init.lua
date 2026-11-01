require("plugs.strap")
local lazy = require("lazy")
lazy.setup({
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("plugs.ts.treesitter")
    end,
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "Format", "FormatToggle", "ConformInfo" },
    keys = {
      { "<leader>lf", "<Cmd>Format<CR>", desc = "Format file" },
      { "<leader>uf", "<Cmd>FormatToggle<CR>", desc = "Toggle format on save" },
    },
    config = function()
      require("plugs.lsp.format")
    end,
  },
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "xml", "javascriptreact", "typescriptreact", "astro" },
    opts = {},
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = "BufRead",
    config = function()
      require("plugs.ui.colorizer")
    end,
    lazy = true,
  },
  {
    "nvim-tree/nvim-web-devicons",
    event = "BufRead",
    config = function()
      require("plugs.ui.devicons")
    end,
    lazy = true,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {},
    event = "BufReadPost",
    config = function()
      require("ibl").setup()
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    lazy = true,
    cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeOpen", "NvimTreeFocus" },
    config = function()
      require("plugs.util.nvim-tree")
    end,
  },
  {
    "nvim-lua/plenary.nvim",
    lazy = true,
  },
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      require("plugs.util.telescope")
    end,
  },
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("Comment").setup({ mappings = { basic = true, extra = true } })
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    lazy = true,
    config = function()
      require("plugs.util.toggleterm")
    end,
    cmd = "ToggleTerm",
  },
  {
    "lewis6991/gitsigns.nvim",
    lazy = true,
    event = { "BufRead" },
    config = function()
      require("plugs.ui.gitsigns")
    end,
  },
  {
    "mason-org/mason.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = {
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    cmd = {
      "MasonInstall",
      "MasonUninstall",
      "Mason",
      "MasonUninstallAll",
      "MasonLog",
    },
    lazy = true,
    config = function()
      require("plugs.lsp.mason")
    end,
  },
  {
    "neovim/nvim-lspconfig",
    enabled = false,
    event = { "BufReadPost", "BufNewFile" },
    lazy = true,
    cmd = { "LspInfo", "LspInstall", "LspUninstall", "LspStart" },
    config = function()
      require("plugs.lsp.lspconfig")
    end,
  },

  -- load luasnips + cmp related in insert mode only
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    lazy = true,
    dependencies = {
      {
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        lazy = true,
        dependencies = "rafamadriz/friendly-snippets",
        config = function()
          require("plugs.lsp.luasnip")
        end,
      },

      -- autopairing of (){}[] etc
      {
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        event = "InsertEnter",
        lazy = true,
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)

          -- setup cmp for autopairs
          local cmp_autopairs = require("nvim-autopairs.completion.cmp")
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },

      -- cmp sources plugins
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      require("plugs.lsp.cmp")
    end,
  },
  {
    "kevinhwang91/nvim-ufo",
    enabled = false,
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    config = function()
      require("plugs.util.ufo")
    end,
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    lazy = true,
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "InsertEnter" },
    opts = {
      signs = false,
    },
  },
  {
    "echasnovski/mini.starter",
    version = false,
    lazy = false,
    config = function()
      require("plugs.ui.starter")
    end,
  },
  {
    "chadcat7/prism",
    lazy = false,
    priority = 1000,
    config = function()
      require("plugs.ui.prism")
    end,
  },
  {
    "wuelnerdotexe/vim-astro",
    ft = "astro",
  },
  {
    "pmizio/typescript-tools.nvim",
    enabled = false,
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
    event = "BufRead",
    ft = { "ts", "astro", "tsx", "jsx", "js", "vue" },
  },
  {
    "prisma/vim-prisma",
    ft = "prisma",
  },
  {
    "elkowar/yuck.vim",
    ft = "yuck",
  },
  {
    "LnL7/vim-nix",
    lazy = true,
    ft = "nix",
  },
}, {
  ui = {
    size = { width = 0.8, height = 0.8 },
    border = "solid",
    icons = {
      cmd = " ",
      config = "",
      event = "",
      ft = " ",
      init = " ",
      import = " ",
      keys = " ",
      lazy = "鈴 ",
      loaded = "●",
      not_loaded = "○",
      plugin = " ",
      runtime = " ",
      source = " ",
      start = "",
      task = "✔ ",
      list = { "●", "➜", "★", "‒" },
    },
    throttle = 20,
  },
  lockfile = vim.env.DOTS_NVIM_LOCKFILE or (vim.fn.stdpath("config") .. "/lazy-lock.json"),
  defaults = { lazy = true },
  install = { missing = false },
  change_detection = { notify = false },
  performance = {
    cache = {
      enabled = true,
      path = vim.fn.stdpath("cache") .. "/lazy/cache",
      ttl = 3600 * 24 * 5,
      disable_events = { "VimEnter", "BufReadPre", "UIEnter" },
    },
    reset_packpath = true,
    rtp = {
      disabled_plugins = {
        "2html_plugin",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "logipat",
        "matchit",
        "matchparen",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "logipat",
        "matchit",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "archlinux",
        "fzf",
        "tutor_mode_plugin",
        "sleuth",
        "vimgrep",
      },
    },
  },
})

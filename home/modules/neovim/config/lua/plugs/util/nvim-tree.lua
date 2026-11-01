require("nvim-tree").setup({
  disable_netrw = true,
  hijack_netrw = false,
  hijack_cursor = true,
  view = { width = 34, side = "left" },
  renderer = {
    root_folder_label = false,
    indent_markers = { enable = true },
    icons = { show = { git = true, folder = true, file = true, folder_arrow = false } },
  },
  filters = {
    dotfiles = false,
    git_ignored = true,
    custom = { "^\\.git$", "^node_modules$", "^\\.cache$" },
  },
  update_focused_file = { enable = true, update_root = false },
  git = { enable = true, ignore = true, timeout = 500 },
  actions = { open_file = { quit_on_open = false, window_picker = { enable = false } } },
})
vim.keymap.set("n", "<leader>cd", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    vim.api.nvim_set_current_dir(vim.fs.dirname(file))
  end
end, { desc = "Change directory to current file" })

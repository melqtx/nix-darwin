local group = vim.api.nvim_create_augroup("UserEditing", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank({ timeout = 150 })
  end,
})
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) and vim.bo[args.buf].buftype == "" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
vim.api.nvim_create_autocmd("VimResized", {
  group = group,
  callback = function()
    vim.schedule(function()
      vim.cmd("redraw!")
    end)
  end,
})
vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = function(data)
    if data.file ~= "" and vim.fn.isdirectory(data.file) == 1 then
      vim.api.nvim_set_current_dir(data.file)
      require("nvim-tree.api").tree.open()
    end
  end,
})

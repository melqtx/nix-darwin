local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  error("Neovim plugins are not restored yet. Run nvim-setup, then reopen Neovim.")
end
vim.opt.rtp:prepend(lazypath)

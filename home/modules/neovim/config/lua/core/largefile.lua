local M = { max_bytes = 1024 * 1024, max_lines = 20000 }

function M.is_large(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
    return false
  end
  local lines = vim.api.nvim_buf_line_count(buf)
  return lines > M.max_lines or vim.api.nvim_buf_get_offset(buf, lines) > M.max_bytes
end

return M

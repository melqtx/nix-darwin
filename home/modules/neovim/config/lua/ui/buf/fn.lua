local M = {}
function M.bufilter()
  local result = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_valid(buf)
      and vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buflisted
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
    then
      result[#result + 1] = buf
    end
  end
  return result
end
local function cycle(delta)
  local bufs = M.bufilter()
  if #bufs == 0 then
    return
  end
  local index = 1
  for i, buf in ipairs(bufs) do
    if buf == vim.api.nvim_get_current_buf() then
      index = (i - 1 + delta) % #bufs + 1
      break
    end
  end
  vim.api.nvim_set_current_buf(bufs[index])
end
function M.tabuflinePrev()
  cycle(-1)
end
function M.tabuflineNext()
  cycle(1)
end
function M.close_buffer(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) then
    return false
  end
  if vim.bo[buf].modified then
    vim.notify("Save this buffer before closing it, or use :bd! to discard changes.", vim.log.levels.WARN)
    return false
  end
  if vim.bo[buf].buftype == "terminal" then
    vim.cmd("confirm bdelete " .. buf)
    return not vim.api.nvim_buf_is_valid(buf)
  end
  local replacement
  for _, other in ipairs(M.bufilter()) do
    if other ~= buf then
      replacement = other
      break
    end
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      replacement = replacement or vim.api.nvim_create_buf(true, false)
      vim.api.nvim_win_set_buf(win, replacement)
    end
  end
  vim.api.nvim_buf_delete(buf, { force = false })
  return true
end
return M

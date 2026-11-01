local M = {}
local buffers = require("ui.buf.fn")
local function escape(text)
  return text:gsub("%%", "%%%%")
end

vim.cmd([[
function! BufflineGoToBuf(bufnr,b,c,d)
  execute 'buffer ' . a:bufnr
endfunction
function! BufflineKillBuf(bufnr,b,c,d)
  call luaeval('require("ui.buf.fn").close_buffer(_A)', a:bufnr)
endfunction
function! ToggleTheme(a,b,c,d)
  lua require('prism.themer'):random()
endfunction
]])

vim.api.nvim_create_user_command("BufflinePrev", buffers.tabuflinePrev, { force = true })
vim.api.nvim_create_user_command("BufflineNext", buffers.tabuflineNext, { force = true })
vim.keymap.set("n", "<Tab>", buffers.tabuflineNext, { desc = "Next file buffer", silent = true })
vim.keymap.set("n", "<S-Tab>", buffers.tabuflinePrev, { desc = "Previous file buffer", silent = true })

function M.getTabline()
  local bufs = buffers.bufilter()
  local names = {}
  for _, buf in ipairs(bufs) do
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":t")
    names[name] = (names[name] or 0) + 1
  end
  local parts = {}
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "NvimTree" then
      local width = vim.api.nvim_win_get_width(win)
      parts[#parts + 1] = "%#BufflineTree#" .. string.rep(" ", math.max(0, width))
      break
    end
  end
  for _, buf in ipairs(bufs) do
    local path = vim.api.nvim_buf_get_name(buf)
    local name = vim.fn.fnamemodify(path, ":t")
    if names[name] > 1 then
      name = vim.fn.fnamemodify(path, ":~:.")
    end
    local active = buf == vim.api.nvim_get_current_buf()
    local hl = active and "BufflineBufOnActive" or "BufflineBufOnInactive"
    local modified = vim.bo[buf].modified and " ●" or ""
    parts[#parts + 1] = "%#"
      .. hl
      .. "#%"
      .. buf
      .. "@BufflineGoToBuf@  "
      .. escape(name)
      .. modified
      .. "  %X%"
      .. buf
      .. "@BufflineKillBuf@ × %X%#BufflineEmptyColor#"
  end
  parts[#parts + 1] = "%=%#BufflineButton#%@ToggleTheme@  %X"
  return table.concat(parts)
end
function M.setup()
  vim.o.showtabline = #buffers.bufilter() > 1 and 2 or 0
  vim.o.tabline = '%!v:lua.require("ui.buf").getTabline()'
end
return M

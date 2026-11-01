local M = { terminals = {}, labels = {}, pending = {} }

function M.root(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if vim.b[buf].jj_workspace then
    return vim.b[buf].jj_workspace
  end
  local name = vim.api.nvim_buf_get_name(buf)
  local base = vim.bo[buf].buftype == "" and name ~= "" and vim.fs.dirname(name) or vim.fn.getcwd()
  local marker = vim.fs.find(".jj", { path = base, upward = true })[1]
  return marker and vim.fs.dirname(marker) or nil
end

function M.refresh()
  local buf = vim.api.nvim_get_current_buf()
  local root = M.root(buf)
  vim.b[buf].jj_label = root and M.labels[root] or nil
  if not root or M.pending[root] then
    return
  end
  M.pending[root] = true
  vim.system(
    {
      "jj",
      "--ignore-working-copy",
      "--no-pager",
      "--color=never",
      "log",
      "--no-graph",
      "-r",
      "@",
      "-T",
      "change_id.shortest(8)",
    },
    { cwd = root, text = true },
    function(result)
      vim.schedule(function()
        M.pending[root] = nil
        M.labels[root] = result.code == 0 and vim.trim(result.stdout) or nil
        for _, other in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(other) and M.root(other) == root then
            vim.b[other].jj_label = M.labels[root]
          end
        end
        vim.cmd("redrawstatus")
      end)
    end
  )
end

local function workspace()
  local root = M.root()
  if not root then
    vim.notify("This folder is not a JJ workspace. Initialize it with jj git init.", vim.log.levels.WARN)
  end
  return root
end

function M.review(args, filetype)
  local root = workspace()
  if not root then
    return
  end
  local command = { "jj", "--no-pager", "--color=never" }
  vim.list_extend(command, args)
  vim.system(command, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(vim.trim(result.stderr or "JJ command failed"), vim.log.levels.ERROR)
        return
      end
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_name(buf, "jj://" .. args[1] .. "-" .. buf)
      vim.b[buf].jj_workspace = root
      vim.bo[buf].bufhidden = "wipe"
      vim.bo[buf].swapfile = false
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result.stdout, "\n", { plain = true }))
      vim.bo[buf].filetype = filetype
      vim.bo[buf].modifiable = false
      vim.cmd("botright split")
      vim.api.nvim_win_set_buf(0, buf)
      vim.api.nvim_win_set_height(0, math.max(5, math.floor(vim.o.lines * 0.3)))
      vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = buf, silent = true, desc = "Close JJ review" })
      M.refresh()
    end)
  end)
end

function M.ui()
  local root = workspace()
  if not root then
    return
  end
  if not M.terminals[root] then
    M.terminals[root] = require("toggleterm.terminal").Terminal:new({
      cmd = "jjui",
      dir = root,
      direction = "float",
      hidden = true,
      on_exit = function()
        vim.schedule(M.refresh)
      end,
    })
  end
  M.terminals[root]:toggle()
end

function M.setup()
  local group = vim.api.nvim_create_augroup("DotsJujutsu", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "DirChanged", "TermClose" }, {
    group = group,
    callback = function()
      vim.schedule(M.refresh)
    end,
  })
  vim.schedule(M.refresh)
end

return M

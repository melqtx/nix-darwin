local M = function()
  local change = vim.b.jj_label
  if change then
    return "%#StalineBranch# jj " .. change:gsub("%%", "%%%%") .. " "
  end
  if not vim.b.gitsigns_head then
    return ""
  end

  local git_status = vim.b.gitsigns_status_dict or {}
  if not git_status.head then
    return ""
  end

  local branch_name = "  " .. git_status.head:gsub("%%", "%%%%") .. " "

  return "%#StalineBranch#" .. branch_name
end

return M

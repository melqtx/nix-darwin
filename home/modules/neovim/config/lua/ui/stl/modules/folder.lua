local fn = vim.fn
local M = function(m)
  if m == "blocks" then
    local directory = "%#StalineFolderText#" .. " " .. fn.fnamemodify(fn.getcwd(), ":t"):gsub("%%", "%%%%") .. " "
    local icon = "%#StalineFolderIcon#" .. " DIR "
    return icon .. directory .. "%#StalineEmptySpace#" .. " "
  elseif m == "fancy" then
    local directory = "%#StalineFolderText#" .. " " .. fn.fnamemodify(fn.getcwd(), ":t"):gsub("%%", "%%%%") .. " "
    local icon = "%#StalineFolderIcon#" .. "  "
    return "%#StalineFolderSep#" .. "" .. icon .. directory .. "%#StalineEmptySpace#" .. " "
  elseif m == "minimal" then
    local directory = "%#StalineFolderTextMinimal#"
      .. " "
      .. fn.fnamemodify(fn.getcwd(), ":t"):gsub("%%", "%%%%")
      .. " "
    return directory .. "%#StalineEmptySpace#"
  else
    return "f"
  end
end

return M

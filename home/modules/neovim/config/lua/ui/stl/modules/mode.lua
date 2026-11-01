local api = vim.api
local modes = require("ui.stl.modes")

local M = function(m)
  local raw_mode = api.nvim_get_mode().mode
  local mode = modes[raw_mode] and raw_mode or raw_mode:sub(1, 1)
  if not modes[mode] then
    mode = "n"
  end
  local sep = "%#" .. modes[mode][2] .. "Sep" .. "#" .. "  "
  local septwo = "%#StalineModeSepTwo" .. "#" .. " "
  if m == "blocks" then
    return "%#" .. modes[mode][2] .. "#" .. " " .. modes[mode][1] .. " "
  elseif m == "minimal" then
    return "%#" .. "StalineModeMinimal" .. "#" .. " " .. modes[mode][1] .. " "
  elseif m == "fancy" then
    return "%#" .. modes[mode][2] .. "#" .. "   " .. modes[mode][1] .. " " .. sep .. septwo .. ""
  else
    return "F"
  end
end

return M

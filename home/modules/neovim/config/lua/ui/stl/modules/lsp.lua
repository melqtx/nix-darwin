-- thanks nvchad
local M = function(m)
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })) do
    if client then
      if (m == 'blocks') then
        return "%#StalineLspIcon#" ..
            " LSP " .. "%#StalineLspNameNormal#" .. " " .. client.name .. " %#StalineEmptySpace#" .. " "
      elseif (m == 'minimal') then
        return "%#StalineSep#| %#StalineEmptySpace#" ..
            "%#StalineLspNameMinimal#" .. client.name .. " %#StalineEmptySpace#"
      elseif (m == 'fancy') then
        return "%#StalineLspIcon#" ..
            "   " .. "%#StalineLspName#" .. " " .. client.name .. " " .. "%#StalineEmptySpace#" .. " "
      else
        return 'f'
      end
    end
  end
end

return M

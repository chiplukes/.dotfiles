-- lua/core/commands.lua
-- All custom user commands centralized
local M = {}

-- =============================================================================
-- Diagnostic Commands for Troubleshooting LSP Issues
-- =============================================================================

-- Command to check what LSP servers are running and their capabilities
vim.api.nvim_create_user_command('LspDebug', function()
  local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
  if #clients == 0 then
    print('No LSP clients attached to current buffer')
    return
  end

  print('=== ACTIVE LSP SERVERS ===')
  for _, client in ipairs(clients) do
    print('Server: ' .. client.name)
    if client.config and client.config.settings then
      print('  Settings configured: Yes')
      if client.name == 'pylsp' and client.config.settings.pylsp and client.config.settings.pylsp.plugins then
        print('  Pylsp plugins:')
        for plugin, config in pairs(client.config.settings.pylsp.plugins) do
          if type(config) == 'table' and config.enabled ~= nil then
            print('    ' .. plugin .. ': ' .. (config.enabled and 'ENABLED' or 'disabled'))
          end
        end
      end
    else
      print('  Settings configured: No')
    end
    print('  Root dir: ' .. (client.config.root_dir or 'unknown'))
    print('  Capabilities: diagnostics=' .. tostring(client.server_capabilities.diagnosticProvider ~= nil))
    print('')
  end
end, { desc = 'Debug LSP server configuration and status' })

return M
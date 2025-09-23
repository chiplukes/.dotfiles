-- lua/plugins/copilot.lua
-- GitHub Copilot - AI-powered code completion
return {
  'github/copilot.vim',
  event = 'InsertEnter',
  config = function()
    -- Disable default keybindings to set custom ones that match VS Code
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_assume_mapped = true

    -- Custom keybindings to match VS Code Copilot extension
    vim.keymap.set('i', '<Tab>', function()
      if vim.fn['copilot#Accept']('') ~= '' then
        return vim.fn['copilot#Accept']('')
      else
        return '<Tab>'
      end
    end, { expr = true, replace_keycodes = false, desc = 'Accept Copilot suggestion or Tab' })

    vim.keymap.set('i', '<C-]>', '<Plug>(copilot-next)', { desc = 'Next Copilot suggestion' })
    vim.keymap.set('i', '<C-[>', '<Plug>(copilot-previous)', { desc = 'Previous Copilot suggestion' })
    vim.keymap.set('i', '<C-\\>', '<Plug>(copilot-dismiss)', { desc = 'Dismiss Copilot suggestion' })

    -- Word-level acceptance (like VS Code Ctrl+Right Arrow)
    vim.keymap.set('i', '<C-Right>', '<Plug>(copilot-accept-word)', { desc = 'Accept Copilot word' })

    -- Show Copilot panel (like VS Code Ctrl+Enter)
    vim.keymap.set('i', '<C-CR>', '<Plug>(copilot-suggest)', { desc = 'Show Copilot suggestions panel' })
  end,
}
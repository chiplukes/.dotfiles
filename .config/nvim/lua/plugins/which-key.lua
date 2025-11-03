-- lua/plugins/which-key.lua
-- Which-key - shows pending keybinds
return {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    -- this setting is independent of vim.o.timeoutlen
    delay = 0,
    -- Expand groups with only one keymap (show the actual keymaps instead of "+1 keymap")
    expand = 1,
    icons = {
      -- set icon mappings to true if you have a Nerd Font
      mappings = vim.g.have_nerd_font,
      -- If you are using a Nerd Font: set icons.keys to an empty table which will use the
      -- default which-key.nvim defined Nerd Font icons, otherwise define a string table
      keys = vim.g.have_nerd_font and {} or {
        Up = '<Up> ',
        Down = '<Down> ',
        Left = '<Left> ',
        Right = '<Right> ',
        C = '<C-…> ',
        M = '<M-…> ',
        D = '<D-…> ',
        S = '<S-…> ',
        CR = '<CR> ',
        Esc = '<Esc> ',
        ScrollWheelDown = '<ScrollWheelDown> ',
        ScrollWheelUp = '<ScrollWheelUp> ',
        NL = '<NL> ',
        BS = '<BS> ',
        Space = '<Space> ',
        Tab = '<Tab> ',
        F1 = '<F1>',
        F2 = '<F2>',
        F3 = '<F3>',
        F4 = '<F4>',
        F5 = '<F5>',
        F6 = '<F6>',
        F7 = '<F7>',
        F8 = '<F8>',
        F9 = '<F9>',
        F10 = '<F10>',
        F11 = '<F11>',
        F12 = '<F12>',
      },
    },

    -- Document existing key chains
    spec = {
      { '<leader>c', group = '📝 [C]ode' },
      { '<leader>ca', group = 'LSP [A]ctions' },
      { '<leader>cp', group = '[P]ython' },
      { '<leader>cg', group = '[G]oto' },
      { '<leader>c.', group = 'Diagnostics' },
      { '<leader>cs', group = '[S]ymbols' },
      { '<leader>cf', group = '[F]ormat' },
      { '<leader>cd', group = '🐛 [D]ebug' },
      { '<leader>s', group = '🔍 [S]earch' },
      { '<leader>m', group = '📌 [M]arkers' },
      { '<leader>mg', group = 'Marker [G]roups' },
      { '<leader>w', group = '🪟 [W]indow' },
      { '<leader>e', group = '📂 [E]xplorer' },
      { '<leader>a', group = '💬 [A]I' },
      { '<leader>l', group = '🎓 [L]earning' },
      { '<leader>lx', group = 'E[x]ecute Code' },
      { '<leader>q', group = '📋 Sessions' },
      { '<leader>g', group = '✨ [G]it' },
    },
  },
}
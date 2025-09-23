-- lua/plugins/luasnip.lua
-- LuaSnip - advanced snippets with custom Python/Verilog snippets
return {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  build = 'make install_jsregexp',
  dependencies = { 'rafamadriz/friendly-snippets' },
  config = function()
    local luasnip = require('luasnip')

    -- Load friendly-snippets
    require('luasnip.loaders.from_vscode').lazy_load()

    -- Load our custom snippets (we'll create these files)
    require('luasnip.loaders.from_lua').load({ paths = vim.fn.stdpath('config') .. '/lua/snippets' })

    -- Snippet expansion and navigation keybindings
    vim.keymap.set({'i', 's'}, '<Tab>', function()
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        return '<Tab>'
      end
    end, {expr = true, silent = true})

    vim.keymap.set({'i', 's'}, '<S-Tab>', function()
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        return '<S-Tab>'
      end
    end, {expr = true, silent = true})

    -- Choice selection
    vim.keymap.set('i', '<C-e>', function()
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end)
  end,
}
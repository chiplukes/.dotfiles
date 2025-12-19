-- lua/plugins/treesitter.lua
-- Treesitter - highlight, edit, and navigate code
return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  -- Lazy load on file events - only loads when you actually open files
  event = { 'BufReadPost', 'BufNewFile', 'BufWritePre', 'VeryLazy' },
  main = 'nvim-treesitter.configs', -- Sets main module to use for opts
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
    -- =============================================================================
    -- Enhanced Treesitter Languages (Phase 2)
    -- =============================================================================
    ensure_installed = {
      -- Base languages
      'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc',

      -- Python and related
      'python', 'toml', 'yaml', 'json', 'requirements',

      -- Verilog/SystemVerilog (if available)
      'verilog',

      -- Web development
      'javascript', 'typescript', 'css', 'scss',

      -- Configuration and data formats
      'dockerfile', 'gitignore', 'gitcommit', 'ini',

      -- Shell and scripting
      'regex', 'ssh_config',

      -- Additional useful languages
      'make', 'cmake', 'ninja',
    },

    -- Autoinstall languages that are not installed
    auto_install = true,

    -- Enhanced highlighting configuration
    highlight = {
      enable = true,
      -- Disable highlighting for very large files (performance)
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,

      -- Some languages depend on vim's regex highlighting system for indent rules
      additional_vim_regex_highlighting = { 'ruby', 'verilog' },
    },

    -- Enhanced indentation
    indent = {
      enable = true,
      disable = { 'ruby', 'python' }, -- Python indentation can be tricky with Treesitter
    },

    -- -- Enhanced incremental selection
    -- incremental_selection = {
    --   enable = true,
    --   keymaps = {
    --     init_selection = '<C-space>',
    --     node_incremental = '<C-space>',
    --     scope_incremental = '<C-s>',
    --     node_decremental = '<M-space>',
    --   },
    -- },

    -- Enhanced text objects (if nvim-treesitter-textobjects is installed)
    textobjects = {
      select = {
        enable = true,
        lookahead = true, -- Automatically jump forward to textobj
        keymaps = {
          -- Python-specific text objects
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',

          -- General text objects
          ['ab'] = '@block.outer',
          ['ib'] = '@block.inner',
          ['al'] = '@loop.outer',
          ['il'] = '@loop.inner',
          ['ad'] = '@conditional.outer',
          ['id'] = '@conditional.inner',
        },
      },

      -- Enhanced movement
      move = {
        enable = true,
        set_jumps = true, -- Add to jumplist
        goto_next_start = {
          [']f'] = '@function.outer',
          [']c'] = '@class.outer',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']C'] = '@class.outer',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[c'] = '@class.outer',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[C'] = '@class.outer',
        },
      },

      -- Swap parameters/arguments
      swap = {
        enable = true,
        swap_next = {
          ['<leader>sn'] = '@parameter.inner',
        },
        swap_previous = {
          ['<leader>sp'] = '@parameter.inner',
        },
      },
    },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
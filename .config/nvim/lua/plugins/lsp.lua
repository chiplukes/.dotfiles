-- lua/plugins/lsp.lua
-- Extracted LSP plugin spec from init.lua
return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    -- Main LSP Configuration
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' }, -- Only load when opening files
    dependencies = {
      { 
        'mason-org/mason.nvim', 
        cmd = { 'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUpdate' },
        opts = {} 
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'j-hui/fidget.nvim',
        opts = {
          notification = {
            window = {
              winblend = 100,
            },
          },
        },
      },
      'saghen/blink.cmp',
    },
    config = function()
      local ok, mod = pcall(require, 'lsp.lsp_config')
      if ok and mod and type(mod.setup) == 'function' then
        mod.setup()
      elseif ok and type(mod) == 'function' then
        -- Backwards compat: module returned a function
        mod()
      else
        vim.notify('Failed to load LSP config: lsp.lsp_config', vim.log.levels.ERROR)
      end
    end,
  },
  { -- Autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      -- =============================================================================
      -- Enhanced Conform Configuration (Phase 2)
      -- =============================================================================
      notify_on_error = true, -- Show notifications for formatting errors

      -- Format on save DISABLED (use <leader>f for manual formatting)
      -- This prevents auto-formatting while auto-save is enabled
      format_on_save = nil,

      -- Alternative: Uncomment below to re-enable format on save for specific files only
      --[[
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype

        -- Disable auto-format for most file types (manual control preferred)
        local disable_filetypes = {
          python = true,     -- Use manual formatting with <leader>f
          lua = true,        -- Use manual formatting with <leader>f
          c = true,
          cpp = true,
          javascript = true,
          typescript = true,
          -- Don't auto-format large Verilog files (can be slow)
          verilog = vim.fn.line('$') > 1000,
          systemverilog = vim.fn.line('$') > 1000,
        }

        if disable_filetypes[ft] then
          return nil
        end

        -- File type specific timeouts
        local timeout_by_ft = {
          python = 2000,      -- Python formatting can be slower
          verilog = 3000,     -- Verilog formatting can be very slow
          systemverilog = 3000,
          default = 1000,
        }

        return {
          timeout_ms = timeout_by_ft[ft] or timeout_by_ft.default,
          lsp_format = 'fallback',
          async = false, -- Synchronous for format on save
        }
      end,
      --]]

      -- Comprehensive formatters by file type
      formatters_by_ft = {
        -- =============================================================================
        -- Lua
        -- =============================================================================
        lua = { 'stylua' },

        -- =============================================================================
        -- Python (Ruff-focused approach like hendrikmi)
        -- =============================================================================
        python = { 'ruff_format', 'ruff_organize_imports' },

        -- =============================================================================
        -- C/C++ (Phase 5: C/C++ Support)
        -- =============================================================================
        c = { 'clang_format' },
        cpp = { 'clang_format' },
        cxx = { 'clang_format' },
        cc = { 'clang_format' },
        h = { 'clang_format' },
        hpp = { 'clang_format' },
        hxx = { 'clang_format' },

        -- =============================================================================
        -- Verilog/SystemVerilog
        -- =============================================================================
        verilog = { 'verible_verilog_format' },
        systemverilog = { 'verible_verilog_format' },

        -- =============================================================================
        -- Web and Configuration Files
        -- =============================================================================
        javascript = { 'prettierd', 'prettier', stop_after_first = true },
        typescript = { 'prettierd', 'prettier', stop_after_first = true },
        javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
        json = { 'fixjson', 'prettier', stop_after_first = true },
        yaml = { 'prettier' },
        html = { 'prettier' },
        css = { 'prettier' },
        markdown = { 'prettier' },

        -- =============================================================================
        -- Shell and Other
        -- =============================================================================
        sh = { 'shfmt' },
        bash = { 'shfmt' },
        zsh = { 'shfmt' },
      },

      -- =============================================================================
      -- Custom Formatter Configurations
      -- =============================================================================
      formatters = {
        -- Enhanced Black configuration
        black = {
          prepend_args = { '--line-length', '88', '--fast' },
        },

        -- Enhanced isort configuration
        isort = {
          prepend_args = { '--profile', 'black', '--line-length', '88' },
        },

        -- Ruff formatter configuration
        ruff_format = {
          command = 'ruff',
          args = { 'format', '--stdin-filename', '$FILENAME', '-' },
          stdin = true,
        },

        ruff_organize_imports = {
          command = 'ruff',
          args = { 'check', '--select', 'I', '--fix', '--stdin-filename', '$FILENAME', '-' },
          stdin = true,
        },

        -- C/C++ clang-format configuration (Phase 5: C/C++ Support)
        clang_format = {
          command = 'clang-format',
          args = {
            '--style={BasedOnStyle: Google, IndentWidth: 4, ColumnLimit: 100}',
            '--assume-filename=$FILENAME'
          },
          stdin = true,
        },

        -- Verible Verilog formatter configuration
        verible_verilog_format = {
          command = 'verible-verilog-format',
          args = {
            '--assignment_statement_alignment=preserve',
            '--case_items_alignment=infer',
            '--class_member_variables_alignment=infer',
            '--formal_parameters_alignment=preserve',
            '--named_parameter_alignment=flush-left',
            '--named_port_alignment=flush-left',
            '--port_declarations_alignment=preserve',
            '$FILENAME',
          },
          stdin = false,
        },

        -- Enhanced stylua configuration
        stylua = {
          prepend_args = { '--indent-type', 'Spaces', '--indent-width', '2' },
        },

        -- Shell formatter configuration
        shfmt = {
          prepend_args = { '-i', '2', '-ci' }, -- 2 spaces, switch case indent
        },
      },
    },
  },
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Snippet Engine
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- 'default' (recommended) for mappings similar to built-in completions
        --   <c-y> to accept ([y]es) the completion.
        --    This will auto-import if your LSP supports it.
        --    This will expand snippets if the LSP sent a snippet.
        -- 'super-tab' for tab to accept
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        --
        -- For an understanding of why the 'default' preset is recommended,
        -- you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        --
        -- All presets have the following mappings:
        -- <tab>/<s-tab>: move to right/left of your snippet expansion
        -- <c-space>: Open menu or open docs if already open
        -- <c-n>/<c-p> or <up>/<down>: Select next/previous item
        -- <c-e>: Hide menu
        -- <c-k>: Toggle signature help
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        -- Custom keymap to exactly match your VS Code keybindings
        preset = 'none', -- Use custom mappings
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-y>'] = { 'accept', 'fallback' },
        ['<C-u>'] = { 'hide', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' }, -- Alternative hide

        -- Keep useful defaults
        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },

        -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
        --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
      },

      appearance = {
        -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'mono',
      },

      completion = {
        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `'prefer_rust_with_warning'`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = 'lua' },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },
    },
  },

}

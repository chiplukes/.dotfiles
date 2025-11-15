local M = {}



function M.setup()
  -- The heavy LSP setup moved from init.lua. This function is called by the plugin spec.
  -- LSP is an initialism you've probably heard, but might not understand what it is.
  --
  -- LSP stands for Language Server Protocol. It's a protocol that helps editors
  -- and language tooling communicate in a standardized fashion.
  --
  -- In general, you have a "server" which is some tool built to understand a particular
  -- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
  -- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
  -- processes that communicate with some "client" - in this case, Neovim!
  --
  -- LSP provides Neovim with features like:
  --  - Go to definition
  --  - Find references
  --  - Autocompletion
  --  - Symbol Search
  --  - and more!
  --
  -- Thus, Language Servers are external tools that must be installed separately from
  -- Neovim. This is where `mason` and related plugins come into play.
  --
  -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
  -- and elegantly composed help section, `:help lsp-vs-treesitter`

  --  This function gets run when an LSP attaches to a particular buffer.
  --    That is to say, every time a new file is opened that is associated with
  --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
  --    function will be executed to configure the current buffer

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
    callback = function(event)
      -- NOTE: Remember that Lua is a real programming language, and as such it is possible
      -- to define small helper and utility functions so you don't have to repeat yourself.
      --
      -- In this case, we create a function that lets us more easily define mappings specific
      -- for LSP related items. It sets the mode, buffer and description for us each time.
      local map = function(keys, func, desc, mode)
        mode = mode or 'n'
        vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
      end

      -- Rename the variable under your cursor.
      --  Most Language Servers support renaming across files, etc.
      map('<leader>carn', vim.lsp.buf.rename, 'Rename')


      -- Execute a code action, usually your cursor needs to be on top of an error
      -- or a suggestion from your LSP for this to activate.
      map('<leader>caa', vim.lsp.buf.code_action, 'Code actions', { 'n', 'x' })

      -- Find references for the word under your cursor.
      map('<leader>cgr', function() require('snacks').picker.lsp_references() end, 'Goto references')

      -- Jump to the implementation of the word under your cursor.
      --  Useful when your language has ways of declaring types without an actual implementation.
      map('<leader>cgi', function() require('snacks').picker.lsp_implementations() end, 'Goto implementation')

      -- Jump to the definition of the word under your cursor.
      --  This is where a variable was first declared, or where a function is defined, etc.
      --  To jump back, press <C-t>.
      map('<leader>cgd', function() require('snacks').picker.lsp_definitions() end, 'Goto definition')

      -- WARN: This is not Goto Definition, this is Goto Declaration.
      --  For example, in C this would take you to the header.
      map('<leader>cgD', vim.lsp.buf.declaration, 'Goto declaration')

      -- Fuzzy find all the symbols in your current document.
      --  Symbols are things like variables, functions, types, etc.
      map('<leader>csof', function() require('snacks').picker.lsp_symbols() end, 'Open document symbols')

      -- Fuzzy find all the symbols in your current workspace.
      --  Similar to document symbols, except searches over your entire project.
      map('<leader>csow', function() require('snacks').picker.lsp_symbols({ workspace = true }) end, 'Open workspace symbols')

      -- Jump to the type of the word under your cursor.
      --  Useful when you're not sure what type a variable is and you want to see
      --  the definition of its *type*, not where it was *defined*.
      map('<leader>cgt', function() require('snacks').picker.lsp_type_definitions() end, 'Goto type definition')

      -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
      ---@param client vim.lsp.Client
      ---@param method vim.lsp.protocol.Method
      ---@param bufnr? integer some lsp support methods only in specific files
      ---@return boolean
      local function client_supports_method(client, method, bufnr)
        if vim.fn.has 'nvim-0.11' == 1 then
          return client:supports_method(method, bufnr)
        else
          return client.supports_method(method, { bufnr = bufnr })
        end
      end

      -- The following two autocommands are used to highlight references of the
      -- word under your cursor when your cursor rests there for a little while.
      --    See `:help CursorHold` for information about when this is executed
      --
      -- When you move your cursor, the highlights will be cleared (the second autocommand).
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
        local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
        vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
          buffer = event.buf,
          group = highlight_augroup,
          callback = vim.lsp.buf.clear_references,
        })

        vim.api.nvim_create_autocmd('LspDetach', {
          group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
          end,
        })
      end

      -- =============================================================================
      -- Enhanced LSP Keybindings (Phase 2)
      -- =============================================================================

      -- Advanced diagnostic navigation (now under <leader>c.)
      -- These are defined in keymaps.lua as VIP and categorized versions
      -- Keeping these here as LSP-specific alternatives if needed

      -- Format buffer (now <leader>cfb in keymaps.lua)
      map('<leader>cfb', function()
        vim.lsp.buf.format({ async = true })
      end, 'Format buffer')

      -- Symbol search (now under <leader>cs)
      map('<leader>cssf', function()
        require('snacks').picker.lsp_symbols()
      end, 'Search document symbols')

      map('<leader>cssw', function()
        require('snacks').picker.lsp_symbols({ workspace = true })
      end, 'Search workspace symbols')

      -- Organize imports (now under <leader>cpi)
      if client and client_supports_method(client, 'textDocument/codeAction', event.buf) then
        map('<leader>cpi', function()
          vim.lsp.buf.code_action({
            context = { only = { 'source.organizeImports' } },
            apply = true
          })
        end, 'Organize imports')
      end

      -- Format current buffer or selection (now <leader>cfb)
      -- Already defined above in the keybindings section

      -- Enhanced signature help with better positioning
      map('<C-k>', function()
        vim.lsp.buf.signature_help()
      end, 'Signature Help', 'i')

      -- Hover with enhanced formatting (K is VIP keymap in keymaps.lua)
      -- Keeping this LSP-specific version here
      map('K', function()
        -- Try LSP hover first, fallback to vim's default K
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result)
          if err or not result or not result.contents then
            -- Fallback to default K behavior
            local word = vim.fn.expand('<cword>')
            vim.cmd('help ' .. word)
          else
            vim.lsp.util.open_floating_preview(result.contents, 'markdown', {
              border = 'rounded',
              max_width = 80,
              max_height = 20,
              focusable = true,
            })
          end
        end)
      end, 'Hover Documentation')

      -- Enhanced symbol search (now under <leader>cs)
      map('<leader>cssf', function()
        require('snacks').picker.lsp_symbols()
      end, 'Search document symbols')

      map('<leader>cssw', function()
        require('snacks').picker.lsp_symbols({ workspace = true })
      end, 'Search workspace symbols')

      -- Language-specific enhancements
      local filetype = vim.bo[event.buf].filetype

      -- Python-specific keybindings (now under <leader>cp)
      if filetype == 'python' then
        map('<leader>cpi', function()
          vim.lsp.buf.code_action({
            context = { only = { 'source.addMissingImports' } },
            apply = true
          })
        end, 'Add missing imports')

        map('<leader>cpr', function()
          vim.lsp.buf.code_action({
            context = { only = { 'refactor.extract' } }
          })
        end, 'Refactor extract')
      end

      -- Verilog-specific keybindings
      if filetype == 'verilog' or filetype == 'systemverilog' then
        map('<leader>vm', function()
          -- Custom module instantiation helper
          local word = vim.fn.expand('<cword>')
          vim.ui.input({ prompt = 'Instance name: ' }, function(instance_name)
            if instance_name then
              local template = string.format('%s %s_inst (\n    // TODO: Connect ports\n);', word, instance_name)
              vim.api.nvim_put({template}, 'l', true, true)
            end
          end)
        end, '[V]erilog [M]odule Instantiation')
      end

      -- Inlay hints toggle (enhanced)
      if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
        map('<leader>th', function()
          local current_setting = vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
          vim.lsp.inlay_hint.enable(not current_setting, { bufnr = event.buf })
          vim.notify(string.format('Inlay hints %s', current_setting and 'disabled' or 'enabled'))
        end, '[T]oggle Inlay [H]ints')
      end
    end,
  })

  -- =============================================================================
  -- Enhanced Diagnostic Configuration (Phase 2)
  -- =============================================================================
  vim.diagnostic.config {
    -- Sort by severity (errors first, then warnings, etc.)
    severity_sort = true,

    -- Enhanced floating window configuration
    float = {
      border = 'rounded',
      source = 'if_many',
      header = '',
      prefix = '',
      -- Add padding and better formatting
      focusable = true,
      style = 'minimal',
      max_width = 80,
      max_height = 20,
    },

    -- Enhanced underline configuration
    underline = {
      severity = { min = vim.diagnostic.severity.HINT } -- Underline all diagnostics
    },

    -- Enhanced signs configuration
    signs = {
      text = vim.g.have_nerd_font and {
        [vim.diagnostic.severity.ERROR] = '󰅚',
        [vim.diagnostic.severity.WARN] = '󰀪',
        [vim.diagnostic.severity.INFO] = '󰋽',
        [vim.diagnostic.severity.HINT] = '󰌶',
      } or {
        [vim.diagnostic.severity.ERROR] = 'E',
        [vim.diagnostic.severity.WARN] = 'W',
        [vim.diagnostic.severity.INFO] = 'I',
        [vim.diagnostic.severity.HINT] = 'H',
      },
      -- Add line highlight for errors
      linehl = {},
      numhl = {
        [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      },
    },

    -- Enhanced virtual text configuration
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      prefix = '●',
      -- Only show virtual text for errors and warnings to reduce noise
      severity = { min = vim.diagnostic.severity.WARN },
      format = function(diagnostic)
        -- Add severity prefix and limit message length
        local max_len = 50
        local message = diagnostic.message
        if #message > max_len then
          message = message:sub(1, max_len - 3) .. '...'
        end

        local severity_icons = {
          [vim.diagnostic.severity.ERROR] = '󰅚',
          [vim.diagnostic.severity.WARN] = '󰀪',
          [vim.diagnostic.severity.INFO] = '󰋽',
          [vim.diagnostic.severity.HINT] = '󰌶',
        }

        local icon = severity_icons[diagnostic.severity] or '●'
        return string.format('%s %s', icon, message)
      end,
    },

    -- Enhanced update behavior
    update_in_insert = false, -- Don't show diagnostics while typing
  }

  -- LSP servers and clients are able to communicate to each other what features they support.
  --  By default, Neovim doesn't support everything that is in the LSP specification.
  --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
  --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
  local capabilities = require('blink.cmp').get_lsp_capabilities()

  -- Enable the following language servers
  --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
  --
  --  Add any additional override configuration in the following tables. Available keys are:
  --  - cmd (table): Override the default command used to start the server
  --  - filetypes (table): Override the default list of associated filetypes for the server
  --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
  --  - settings (table): Override the default settings passed when initializing the server.
  --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
  local servers = {
    -- Python: Use pyright for language features (completion, hover, etc.)
    -- and Ruff for linting/formatting
    pyright = {
      -- Cross-platform pyright path - will use .exe on Windows, no extension on Linux
      cmd = (function()
        local pyright_path = vim.fn.expand('~/.local/bin/pyright-langserver')
        if vim.fn.has('win32') == 1 then
          pyright_path = pyright_path .. '.exe'
        end
        return { pyright_path, '--stdio' }
      end)(),
      settings = {
        python = {
          analysis = {
            -- Disable all type checking diagnostics (let Ruff handle linting)
            typeCheckingMode = "off",
            diagnosticMode = "openFilesOnly",
            -- Disable diagnostic rules
            diagnosticSeverityOverrides = {
              reportMissingImports = "none",
              reportUndefinedVariable = "none",
            },
          },
        },
      },
    },

    -- Ruff: use the new built-in LSP server (ruff server)
    ruff = {
      -- Cross-platform ruff path - will use .exe on Windows, no extension on Linux
      cmd = (function()
        local ruff_path = vim.fn.expand('~/.local/bin/ruff')
        if vim.fn.has('win32') == 1 then
          ruff_path = ruff_path .. '.exe'
        end
        return { ruff_path, 'server' }
      end)(),
    },

    -- =============================================================================
    -- C/C++ LSP Configuration (Phase 5: C/C++ Support)
    -- =============================================================================
    clangd = {
      cmd = {
        'clangd',
        '--background-index',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--completion-style=detailed',
        '--function-arg-placeholders',
        '--fallback-style=llvm',
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
      },
      root_dir = function(fname)
        return require('lspconfig.util').root_pattern(
          '.clangd',
          '.clang-tidy',
          '.clang-format',
          'compile_commands.json',
          'compile_flags.txt',
          'configure.ac',
          '.git'
        )(fname) or vim.fn.getcwd()
      end,
    },

    -- =============================================================================
    -- Verilog/SystemVerilog LSP Configuration
    -- =============================================================================
    -- Note: svls (SystemVerilog Language Server) is not available in Mason
    -- and would need to be manually installed. Using Verible instead.

    -- Verible language server (available in Mason)
    verible = {
      cmd = { 'verible-verilog-ls', '--rules_config_search' },
      filetypes = { 'verilog', 'systemverilog' },
      root_dir = function(fname)
        return require('lspconfig.util').root_pattern(
          '.rules.verible_lint',
          'verible.filelist',
          '.git'
        )(fname) or vim.fn.getcwd()
      end,
    },

    -- =============================================================================
    -- Lua LSP (Enhanced)
    -- =============================================================================
    lua_ls = {
      -- cmd = { ... },
      -- filetypes = { ... },
      -- capabilities = {},
      settings = {
        Lua = {
          completion = {
            callSnippet = 'Replace',
          },
          -- Enhanced Lua diagnostics
          diagnostics = {
            -- Recognize vim global
            globals = { 'vim', 'require' },
            -- Disable noisy warnings for Neovim config
            disable = { 'missing-fields', 'incomplete-signature-doc' },
          },
          -- Workspace configuration for Neovim development
          workspace = {
            -- Make the server aware of Neovim runtime files
            library = vim.api.nvim_get_runtime_file('', true),
            checkThirdParty = false, -- Disable third-party checking
          },
          -- Enhanced telemetry settings
          telemetry = { enable = false },
        },
      },
    },
  }

  -- Ensure the servers and tools above are installed
  --
  -- To check the current status of installed tools and/or manually install
  -- other tools, you can run
  --    :Mason
  --
  -- You can press `g?` for help in this menu.
  --
  -- Note: mason-tool-installer is configured in lua/plugins/lsp.lua
  -- and will automatically install the tools listed there on startup.

  require('mason-lspconfig').setup {
    handlers = {
      -- Default handler for all servers managed by mason-lspconfig
      function(server_name)
        local server = servers[server_name] or {}
        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
        require('lspconfig')[server_name].setup(server)
      end,
    },
  }

  -- Manually setup pyright since it's installed via UV, not Mason
  local pyright_config = servers.pyright or {}
  pyright_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, pyright_config.capabilities or {})
  require('lspconfig').pyright.setup(pyright_config)

  -- Manually setup ruff since it's installed via UV, not Mason
  local ruff_config = servers.ruff or {}
  ruff_config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, ruff_config.capabilities or {})
  require('lspconfig').ruff.setup(ruff_config)
end

return M

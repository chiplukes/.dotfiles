-- lua/core/options.lua
-- All Neovim editor options centralized
local M = {}

-- [[ Setting options ]]
-- See `:help vim.o`
-- For more options, you can see `:help option-list`

-- Make line numbers default
vim.o.number = true
-- You can also add relative line numbers, to help with jumping.
-- Experiment for yourself to see if you like it!
-- vim.o.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.o.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
-- Schedule the setting after `UiEnter` because it can increase startup-time.
-- Remove this option if you want your OS clipboard to remain independent.
-- See `:help 'clipboard'`
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
-- See `:help 'list'` and `:help 'listchars'`
-- Notice listchars is set using `vim.opt` instead of `vim.o`.
-- It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
-- See `:help lua-options` and `:help lua-options-guide`
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.o.inccommand = 'split'

-- Show which line your cursor is on
vim.o.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
-- vim.o.scrolloff = 10
vim.o.smoothscroll = true  -- Enable smooth scrolling

-- If performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.o.confirm = true

-- Enable tabline and show full paths in tabs
vim.o.showtabline = 2  -- Always show tabline (0=never, 1=only if multiple tabs, 2=always)

-- Custom tabline function to show full paths with enhanced active tab highlighting
function _G.custom_tabline()
  -- Define custom highlight groups for better active tab visibility
  vim.api.nvim_set_hl(0, 'TabLineActive', {
    fg = '#ffffff', bg = '#0078d4', bold = true
  })
  vim.api.nvim_set_hl(0, 'TabLineInactive', {
    fg = '#888888', bg = '#2d2d2d'
  })

  local s = ''
  local current_tab = vim.fn.tabpagenr()

  for i = 1, vim.fn.tabpagenr('$') do
    local is_active = (i == current_tab)

    -- Enhanced highlighting for active vs inactive tabs
    if is_active then
      s = s .. '%#TabLineActive#'
    else
      s = s .. '%#TabLineInactive#'
    end

    -- Set the tab page number for mouse clicks
    s = s .. '%' .. i .. 'T'

    -- Get the buffer name for this tab
    local buflist = vim.fn.tabpagebuflist(i)
    local winnr = vim.fn.tabpagewinnr(i)
    local bufname = vim.fn.bufname(buflist[winnr])

    -- Format the tab label with full path and enhanced active tab styling
    local label
    if bufname == '' then
      if is_active then
        label = ' ▶ [No Name] ◀ '
      else
        label = ' [No Name] '
      end
    else
      -- Show full path but make it more readable
      local full_path = vim.fn.fnamemodify(bufname, ':p')
      local home = vim.fn.expand('~')

      -- Replace home directory with ~ for readability
      local path_display
      if full_path:sub(1, #home) == home then
        path_display = '~' .. full_path:sub(#home + 1)
      else
        path_display = full_path
      end

      -- Add visual indicators and spacing for active tab
      if is_active then
        label = ' ▶ ' .. path_display .. ' ◀ '
      else
        label = ' ' .. path_display .. ' '
      end

      -- Add modified indicator
      if vim.fn.getbufvar(buflist[winnr], '&modified') == 1 then
        if is_active then
          label = label .. '[●] '
        else
          label = label .. '[+] '
        end
      end
    end

    s = s .. label
  end

  -- Fill the rest of the tabline
  s = s .. '%#TabLineFill#%T'

  -- Add close button on the right
  if vim.fn.tabpagenr('$') > 1 then
    s = s .. '%=%#TabLine#%999XX'
  end

  return s
end

-- Set the custom tabline
vim.o.tabline = '%!v:lua.custom_tabline()'

return M

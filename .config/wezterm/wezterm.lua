-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

local function get_launch_cwd(cmd)
  if cmd and cmd.cwd then
    return cmd.cwd
  end

  return wezterm.procinfo.current_working_dir_for_pid(wezterm.procinfo.pid()) or wezterm.home_dir
end

local function set_tab_title(tab, title)
  if tab then
    tab:set_title(title)
  end
end

local function spawn_peovim_dev_layout(window, cwd)
  set_tab_title(window:active_tab(), "terminal")

  local peovim_tab = window:spawn_tab {
    cwd = cwd,
    args = { "peovim", "." },
  }
  set_tab_title(peovim_tab, "peovim")

  local lazygit_tab = window:spawn_tab {
    cwd = cwd,
    args = { "lazygit" },
  }
  set_tab_title(lazygit_tab, "lazygit")
end

local function show_startup_menu(window, pane, mux_window, cwd)
  window:perform_action(
    act.InputSelector {
      title = "Choose startup layout",
      description = "Enter accepts, Esc keeps a single terminal tab, / filters",
      choices = {
        { id = "terminal", label = "terminal - single tab" },
        { id = "peovim-dev", label = "peovim dev - terminal + peovim + lazygit" },
      },
      action = wezterm.action_callback(function(_, _, id)
        if id == "peovim-dev" then
          spawn_peovim_dev_layout(mux_window, cwd)
          return
        end

        set_tab_title(mux_window:active_tab(), "terminal")
      end),
    },
    pane
  )
end

local function schedule_startup_menu(mux_window, cwd)
  wezterm.time.call_after(0.1, function()
    local gui_window = mux_window:gui_window()
    local active_tab = mux_window:active_tab()
    local pane = active_tab and active_tab:active_pane()

    if gui_window and pane then
      show_startup_menu(gui_window, pane, mux_window, cwd)
    end
  end)
end

wezterm.on("gui-startup", function(cmd)
  local cwd = get_launch_cwd(cmd)

  if cmd then
    cmd.cwd = cmd.cwd or cwd
  end

  local tab, pane, window = mux.spawn_window(cmd or { cwd = cwd })
  set_tab_title(tab, "terminal")

  schedule_startup_menu(window, cwd)
end)

wezterm.on("update-right-status", function(window, _)
  window:set_right_status(wezterm.format {
    { Foreground = { AnsiColor = "Silver" } },
    { Text = " A+S+N:new  A+S+H/L:tabs  A+S+J/K:panes  A+S+_:split  F11:fullscreen " },
  })
end)

-- This will hold the configuration.
local config = wezterm.config_builder()

config.default_gui_startup_args = { "start", "--always-new-process", "--cwd", "." }

-- Set default shell based on OS
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  -- Use PowerShell on Windows
  config.default_prog = { "pwsh.exe" } -- Use "powershell.exe" for Windows PowerShell 5.1
end


-- Apply globally to enforce it across any unexpected fallbacks
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

config.font = wezterm.font_with_fallback {
  -- Explicitly targets the clean, built-in monospaced engine
  { family = 'JetBrains Mono', harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }, weight = 'Regular' },
  { family = 'Symbols Nerd Font' }, 
}
config.font_size = 12.0

-- Choose a color scheme (exact names from available schemes)
--config.color_scheme = "Catppuccin Mocha" -- Popular options: "Dracula", "Nord (Gogh)", "Catppuccin Mocha", "Gruvbox Dark (Gogh)", "Monokai Remastered"
config.color_scheme = "Campbell (Gogh)" -- Popular options: "Dracula", "Nord (Gogh)", "Catppuccin Mocha", "Gruvbox Dark (Gogh)", "Monokai Remastered"

config.colors = {
  scrollbar_thumb = '#ffffff',
}

-- Adjust window opacity
config.window_background_opacity = 1.0

-- Window padding for a cleaner look
config.window_padding = {
  left = 2,
  right = '1cell',
  top = 0,
  bottom = 0,
}

-- Enable or disable the tab bar
config.enable_tab_bar = true

-- Always show the tab bar (needed for right-status cheat sheet)
config.hide_tab_bar_if_only_one_tab = false

-- Scrollback buffer (lines to keep in history)
config.scrollback_lines = 10000

-- Enable scroll bar
config.enable_scroll_bar = true

-- Cursor style and blinking
config.default_cursor_style = "BlinkingBar" -- Options: "SteadyBlock", "BlinkingBlock", "SteadyBar", "BlinkingBar", "SteadyUnderline", "BlinkingUnderline"
config.cursor_blink_rate = 500

-- Disable annoying audible bell
config.audible_bell = "Disabled"

-- Use fancy tab bar (more modern look)
config.use_fancy_tab_bar = true

-- Automatically reload config when it changes
config.automatically_reload_config = true

-- Hyperlink rules (make URLs clickable)
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Inactive pane dimming
config.inactive_pane_hsb = {
  saturation = 0.9,
  brightness = 0.8,
}

-- Disable default key assignments that might interfere with terminal apps
config.disable_default_key_bindings = false

-- Configure keybindings
config.keys = {
  -- Alt+Shift+N: choose between new tab or horizontal split
  {
    key = "n",
    mods = "ALT|SHIFT",
    action = wezterm.action_callback(function(window, pane)
      window:perform_action(
        act.InputSelector {
          title = "New pane",
          choices = {
            { id = "tab",   label = "New tab" },
            { id = "split", label = "Horizontal split" },
          },
          action = wezterm.action_callback(function(win, pan, id)
            if id == "tab" then
              win:perform_action(
                act.PromptInputLine {
                  description = "Tab name (Enter to skip):",
                  action = wezterm.action_callback(function(w, p, line)
                    w:perform_action(act.SpawnTab("DefaultDomain"), p)
                    if line and line ~= "" then
                      wezterm.time.call_after(0.05, function()
                        w:active_tab():set_title(line)
                      end)
                    end
                  end),
                },
                pan
              )
            elseif id == "split" then
              win:perform_action(act.SplitVertical { domain = "CurrentPaneDomain" }, pan)
            end
          end),
        },
        pane
      )
    end),
  },

--   -- Example: Close the current tab with Ctrl+Shift+W
--   { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab { confirm = true } },

  -- Example: Toggle full screen with F11
  { key = "F11", action = wezterm.action.ToggleFullScreen },

  -- Cycle through tabs with Alt+Shift+H/L
  { key = "h", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "l", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(1) },

--   -- Split panes
--   { key = "|", mods = "ALT|SHIFT", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
   { key = "_", mods = "ALT|SHIFT", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },

--   -- Navigate between panes
--   { key = "LeftArrow", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
--   { key = "RightArrow", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
   { key = "j", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Prev") },
   { key = "k", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Next") },

--   -- Resize panes
--   { key = "LeftArrow", mods = "CTRL|SHIFT|ALT", action = wezterm.action.AdjustPaneSize { "Left", 5 } },
--   { key = "RightArrow", mods = "CTRL|SHIFT|ALT", action = wezterm.action.AdjustPaneSize { "Right", 5 } },
--   { key = "UpArrow", mods = "CTRL|SHIFT|ALT", action = wezterm.action.AdjustPaneSize { "Up", 5 } },
--   { key = "DownArrow", mods = "CTRL|SHIFT|ALT", action = wezterm.action.AdjustPaneSize { "Down", 5 } },

--   -- Close pane
--   { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentPane { confirm = true } },

  -- Copy/Paste
  { key = "c", mods = "CTRL|SHIFT", action = wezterm.action.CopyTo("Clipboard") },
  { key = "v", mods = "CTRL|SHIFT", action = wezterm.action.PasteFrom("Clipboard") },
  { key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },

--   -- Search
--   { key = "f", mods = "CTRL|SHIFT", action = wezterm.action.Search("CurrentSelectionOrEmptyString") },

    -- Disable default assignment for Ctrl+R to avoid conflicts
  { key = "r", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment},
 
  -- Send newline sequence instead of Enter 
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = wezterm.action.SendString '\n',
  },
}

-- Finally, return the configuration to wezterm
return config
-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Set default shell based on OS
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  -- Use PowerShell on Windows
  config.default_prog = { "pwsh.exe" } -- Use "powershell.exe" for Windows PowerShell 5.1
end

-- Set the font and font size
config.font = wezterm.font("JetBrains Mono")
config.font_size = 10.0

-- Choose a color scheme (exact names from available schemes)
config.color_scheme = "Catppuccin Mocha" -- Popular options: "Dracula", "Nord (Gogh)", "Catppuccin Mocha", "Gruvbox Dark (Gogh)", "Monokai Remastered"

-- Adjust window opacity
config.window_background_opacity = 0.95

-- Window padding for a cleaner look
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

-- Enable or disable the tab bar
config.enable_tab_bar = true

-- Hide the tab bar if only one tab is open
config.hide_tab_bar_if_only_one_tab = true

-- Scrollback buffer (lines to keep in history)
config.scrollback_lines = 10000

-- Enable scroll bar
config.enable_scroll_bar = false

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
  -- Example: Spawn a new tab with Ctrl+Shift+T
  { key = "n", mods = "ALT|SHIFT", action = wezterm.action.SpawnTab("DefaultDomain") },

--   -- Example: Close the current tab with Ctrl+Shift+W
--   { key = "w", mods = "CTRL|SHIFT", action = wezterm.action.CloseCurrentTab { confirm = true } },

  -- Example: Toggle full screen with F11
  { key = "F11", action = wezterm.action.ToggleFullScreen },

  -- Cycle through tabs with Alt+Shift+H/L
  { key = "h", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(-1) },
  { key = "l", mods = "ALT|SHIFT", action = wezterm.action.ActivateTabRelative(1) },

--   -- Split panes
--   { key = "|", mods = "CTRL|SHIFT", action = wezterm.action.SplitHorizontal { domain = "CurrentPaneDomain" } },
--   { key = "_", mods = "CTRL|SHIFT", action = wezterm.action.SplitVertical { domain = "CurrentPaneDomain" } },

--   -- Navigate between panes
--   { key = "LeftArrow", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Left") },
--   { key = "RightArrow", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Right") },
--   { key = "UpArrow", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Up") },
--   { key = "DownArrow", mods = "ALT|SHIFT", action = wezterm.action.ActivatePaneDirection("Down") },

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
}

-- Finally, return the configuration to wezterm
return config
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

local function spawn_nvim_dev_layout(window, cwd)
  set_tab_title(window:active_tab(), "terminal")

  local nvim_tab = window:spawn_tab {
    cwd = cwd,
    args = { "nvim", "." },
  }
  set_tab_title(nvim_tab, "nvim")

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
        { id = "nvim-dev", label = "nvim dev - terminal + neovim + lazygit" },
      },
      action = wezterm.action_callback(function(_, _, id)
        if id == "nvim-dev" then
          spawn_nvim_dev_layout(mux_window, cwd)
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

-- This will hold the configuration.
local config = wezterm.config_builder()

config.default_gui_startup_args = { "start", "--always-new-process", "--cwd", "." }

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

    -- Disable default assignment for Ctrl+R to avoid conflicts
  { key = "r", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment},

}

-- Finally, return the configuration to wezterm
return config
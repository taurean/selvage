-- ~/.config/wezterm/wezterm.lua
-- Selvage-managed. See ~/Developer/selvage/dot_config/wezterm/wezterm.lua

local wezterm = require "wezterm"
local act = wezterm.action

local dev_dir = wezterm.home_dir .. "/Developer"

return {
  color_scheme = wezterm.gui.get_appearance():find("Dark") and "flexoki-dark" or "flexoki-light",
  font_size = 14,
  hide_tab_bar_if_only_one_tab = true,

  -- New WezTerm tabs/windows start from the repos directory by default.
  default_cwd = dev_dir,

  launch_menu = nil,

  -- URL clicking: a plain click opens a link (WezTerm default) unless the
  -- running program captures the mouse (nvim with `mouse` set). Shift-Click
  -- bypasses that capture; CMD-Click, wired up below, is the macOS-native gesture.
  mouse_bindings = {
    -- CMD-Click opens the hyperlink under the cursor.
    {
      event = { Up = { streak = 1, button = "Left" } },
      mods = "CMD",
      action = act.OpenLinkAtMouseCursor,
    },
    -- Suppress the corresponding Down event so CMD-Click doesn't also move the
    -- cursor / start a selection before the link opens.
    {
      event = { Down = { streak = 1, button = "Left" } },
      mods = "CMD",
      action = act.Nop,
    },
  },

  -- Frameless: drop the macOS title bar so the terminal chrome is flush.
  -- Tab bar (when more than one tab) is still drawn by WezTerm.
  window_decorations = "RESIZE",
}

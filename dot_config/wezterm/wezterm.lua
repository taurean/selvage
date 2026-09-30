-- ~/.config/wezterm/wezterm.lua
-- Selvage-managed. See ~/Developer/selvage/dot_config/wezterm/wezterm.lua

local wezterm = require "wezterm"
local act = wezterm.action

local dev_dir = wezterm.home_dir .. "/Developer"
local tmux_cmd = string.format(
  "tmux attach -t selvage 2>/dev/null || tmux new-session -s selvage -c %q",
  dev_dir
)

return {
  color_scheme = wezterm.gui.get_appearance():find("Dark") and "flexoki-dark" or "flexoki-light",
  font_size = 14,
  hide_tab_bar_if_only_one_tab = true,

  -- New WezTerm tabs/windows start from the repos directory by default.
  default_cwd = dev_dir,

  -- Launch into the persistent tmux session. If it doesn't exist, create it in
  -- the repos directory too, so a fresh terminal starts in ~/Developer.
  default_prog = { "zsh", "-lc", tmux_cmd },

  launch_menu = nil,

  -- URL clicking: tmux `mouse on` swallows plain clicks before WezTerm sees
  -- them, so links aren't clickable by default. Two ways to open a link:
  --   1. Shift-Click  -> WezTerm's built-in "bypass mouse reporting" gesture
  --                      (works with zero config; the click skips tmux).
  --   2. CMD-Click    -> the macOS-native gesture, wired up below.
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

local wezterm = require("wezterm")

return {
  window_decorations = "RESIZE",
  -- window_close_confirmation = "NeverPrompt",
  -- color_scheme = "One Dark (Gogh)",
  color_scheme = "Tokyo Night",
  use_fancy_tab_bar = false,
  enable_tab_bar = true,
  show_tab_index_in_tab_bar = false,
  hide_tab_bar_if_only_one_tab = false,
  window_padding = {
    left = 10,
    right = 0,
    top = 20,
    bottom = 0,
  },
  -- initial_rows = 60,
  -- initial_cols = 200,
  inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
  },
  window_background_opacity = 0.9,
  text_background_opacity = 0.95,
  status_update_interval = 1000,
  font = wezterm.font_with_fallback({
    "JetBrainsMono Nerd Font",
    "FiraCode Nerd Font",
  }),
}

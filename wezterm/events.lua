local wezterm = require("wezterm")

-- event: gui-startup
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
  local _, _, window = mux.spawn_window(cmd or {})
  if wezterm.target_triple:find("linux") then
    wezterm.sleep_ms(100)
  end
  local gui_win = window:gui_window()
  gui_win:maximize()

  -- 根据 DPI 调整字体大小
  local screens = wezterm.gui.screens()
  local dpi = screens.active and screens.active.effective_dpi or 96
  local base_font_size = 12.0
  local base_dpi = 96.0
  local scaled_font_size = base_font_size * (dpi / base_dpi)
  wezterm.log_info("DPI: " .. dpi .. ", scaled font size: " .. scaled_font_size)
  gui_win:set_config_overrides({ font_size = scaled_font_size })
end)

wezterm.on("update-right-status", function(window)
  local date = wezterm.strftime("%Y-%m-%d %H:%M:%S")

  window:set_right_status(wezterm.format({
    { Text = " " },
    { Foreground = { Color = "#fffff" } },
    { Background = { Color = "rgba(0, 0, 0, 0.7)" } },
    { Attribute = { Intensity = "Bold" } },
    { Text = "  " .. date .. " " },
  }))
end)

-- tabs title: z means zoomed
wezterm.on("format-tab-title", function(tab)
  local cn_chars = { "壹", "贰", "叁", "肆", "伍", "陆", "柒", "捌", "玖", "拾" }
  local suffix = tab.active_pane.is_zoomed and "z " or " "
  local i = tab.tab_index + 1
  local text = " " .. (cn_chars[i] or i) .. suffix
  return {
    { Foreground = { Color = tab.is_active and "#ffffff" or "#666666" } },
    { Text = text },
  }
end)

wezterm.on("trigger-log", function(window)
  local screens = wezterm.gui.screens()
  wezterm.log_info(screens)
end)

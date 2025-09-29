local wezterm = require 'wezterm'

local config = {}

-- === Appearance ===
config.color_scheme = "Catppuccin Macchiato"  -- Set color scheme
config.color_scheme = "Catppuccin Macchiato"  -- Set color scheme
config.font = wezterm.font_with_fallback({
  "Hack Nerd Font Mono",  -- Primary font for English
  "Noto Sans CJK SC",     -- Fallback for Simplified Chinese
  "Noto Sans CJK TC",     -- Fallback for Traditional Chinese
})
config.font_size = 12.0  -- Set font size
config.window_background_opacity = 0.9  -- Set transparency (0.0 is fully transparent, 1.0 is fully opaque)

-- === Cursor Settings ===
config.hide_mouse_cursor_when_typing = true  -- Hide mouse cursor while typing
config.default_cursor_style = "BlinkingBar"  -- Cursor style (a blinking bar for active typing)
config.cursor_thickness = "0.07cell"  -- Set cursor thickness (in terms of cells)
config.cursor_blink_rate = 700  -- Cursor blink rate in milliseconds
config.cursor_blink_ease_in = "Constant"  -- Cursor blink fade-in behavior (no fading)
config.cursor_blink_ease_out = "Constant"  -- Cursor blink fade-out behavior (no fading)

-- === Window Behavior ===
config.window_decorations = "RESIZE"  -- Set window decorations (integrated buttons with resize)
config.native_macos_fullscreen_mode = false  -- Disables native fullscreen for macOS, use WezTerm's own fullscreen
config.use_fancy_tab_bar = true  -- This separates tabs from titlebar controls
config.tab_bar_at_bottom = false  -- Set to true if you want tabs at bottom

-- === Keybindings ===
config.keys = {
  -- Vertical split using Control + Option + Shift + Down Arrow
  {
    key = 'DownArrow',
    mods = 'CTRL|OPT|SHIFT',
    action = wezterm.action{SplitVertical={domain="CurrentPaneDomain"}},
  },

  -- Horizontal split using Control + Option + Shift + Right Arrow
  {
    key = 'RightArrow',
    mods = 'CTRL|OPT|SHIFT',
    action = wezterm.action{SplitHorizontal={domain="CurrentPaneDomain"}},
  },

}

return config

{ ... }:

{
  flake.homeModules.ghostty = {
    xdg.configFile."ghostty/config".text = /* conf */ ''
      font-family = Berkeley Mono 2.0
      font-size = 15

      background = 1e1e2e
      foreground = cdd6f4
      cursor-color = f5e0dc
      selection-background = 585b70
      selection-foreground = cdd6f4

      shell-integration = fish

      window-decoration = false
      macos-titlebar-style = hidden
      gtk-tabs-location = hidden

      window-padding-x = 8
      window-padding-y = 8

      background-opacity = 0.95
      background-blur-radius = 20

      cursor-style = block
      cursor-style-blink = false

      confirm-close-surface = false

      copy-on-select = clipboard
      macos-option-as-alt = true

      window-save-state = always
      window-inherit-working-directory = true

      mouse-hide-while-typing = true

      keybind = super+t=unbind
      keybind = super+w=unbind
      keybind = super+h=unbind
      keybind = super+l=unbind
      keybind = super+shift+h=unbind
      keybind = super+shift+l=unbind
      keybind = ctrl+h=unbind
      keybind = ctrl+j=unbind
      keybind = ctrl+k=unbind
      keybind = ctrl+l=unbind
    '';
  };
}

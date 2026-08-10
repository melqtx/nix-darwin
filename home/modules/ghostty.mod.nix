{ ... }:

{
  flake.homeModules.ghostty =
    { lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe;

      zellij = getExe pkgs.zellij;
    in
    {
      xdg.configFile."ghostty/config".text = /* conf */ ''
        # The plain fira-code package registers only "Light" faces on macOS
        # (no true Regular/Bold), which renders everything semi-bold. The
        # nerd-fonts build ships a proper face set.
        font-family = FiraCode Nerd Font Mono
        font-size = 15

        theme = Vesper

        command = direct:${zellij} attach --create main

        shell-integration = detect
        shell-integration-features = no-cursor,sudo,no-title

        fullscreen = false
        macos-titlebar-style = transparent
        window-colorspace = display-p3
        window-width = 120
        window-height = 1000
        gtk-tabs-location = hidden

        window-padding-x = 8
        window-padding-y = 8

        background-opacity = 1
        background-blur-radius = 40
        unfocused-split-opacity = 0.50

        cursor-style = block
        cursor-style-blink = false
        cursor-color = #ffc799
        cursor-text = #101010

        scrollback-limit = 104857600

        confirm-close-surface = true

        copy-on-select = clipboard
        macos-option-as-alt = true

        window-save-state = never
        window-inherit-working-directory = true

        mouse-hide-while-typing = true

        quick-terminal-position = center
        quick-terminal-screen = mouse
        quick-terminal-size = 100%,100%
        quick-terminal-animation-duration = 0
        quick-terminal-autohide = false
        quick-terminal-keyboard-interactivity = exclusive

        keybind = global:ctrl+`=toggle_quick_terminal
        keybind = shift+enter=text:\x1b\r

        keybind = super+t=unbind
        keybind = super+w=unbind
        keybind = super+h=unbind
        keybind = super+l=unbind
        keybind = super+shift+t=unbind
        keybind = super+shift+w=unbind
        keybind = super+shift+h=unbind
        keybind = super+shift+l=unbind
        keybind = ctrl+h=unbind
        keybind = ctrl+j=unbind
        keybind = ctrl+k=unbind
        keybind = ctrl+l=unbind
      '';
    };
}

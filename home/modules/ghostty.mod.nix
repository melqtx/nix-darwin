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
        font-family = Berkeley Mono 2.0
        font-size = 15

        command = direct:${zellij} --layout clean

        # Gruvbox Dark: the warm browns and oranges suit the desktop wallpaper.
        background = 282828
        foreground = ebdbb2
        cursor-color = fabd2f
        selection-background = 504945
        selection-foreground = ebdbb2

        palette = 0=#282828
        palette = 1=#cc241d
        palette = 2=#98971a
        palette = 3=#d79921
        palette = 4=#458588
        palette = 5=#b16286
        palette = 6=#689d6a
        palette = 7=#a89984
        palette = 8=#928374
        palette = 9=#fb4934
        palette = 10=#b8bb26
        palette = 11=#fabd2f
        palette = 12=#83a598
        palette = 13=#d3869b
        palette = 14=#8ec07c
        palette = 15=#ebdbb2

        shell-integration = detect

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

        window-save-state = never
        window-inherit-working-directory = true

        mouse-hide-while-typing = true

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

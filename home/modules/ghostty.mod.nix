{ config, self, ... }:

let
  inherit (config) theme;
in
{
  flake.darwinModules.ghostty = { config, lib, ... }: {
    imports = [
      self.darwinModules.homebrew
      self.darwinModules.home-manager
    ];
    homebrew.casks = lib.lists.singleton "ghostty";
    home-manager.users.${config.system.primaryUser}.imports =
      lib.lists.singleton self.homeModules.ghostty;
  };

  flake.homeModules.ghostty = { lib, pkgs, ... }: {
    programs.fish.interactiveShellInit = /* fish */ ''
      if not set --query ZELLIJ
        if test -r "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
          source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
        end
      end
    '';

    programs.ghostty = {
      enable = true;
      package = null;
      enableFishIntegration = false;
      settings = {
        font-family = theme.terminalFont;
        font-size = theme.fontSize;
        # Keep Vesper's distinct normal and bright ANSI colors.
        theme = "Vesper";
        background = theme.palette.terminalBackground;
        foreground = theme.palette.terminalForeground;
        selection-background = theme.palette.terminalBorder;
        selection-foreground = theme.palette.terminalBackground;
        command = "direct:${lib.meta.getExe pkgs.zellij} attach --create main";
        shell-integration = "detect";
        shell-integration-features = "no-cursor,sudo,no-title";
        fullscreen = false;
        macos-titlebar-style = "hidden";
        window-colorspace = "display-p3";
        window-width = 120;
        window-padding-x = 8;
        window-padding-y = 8;
        background-opacity = 1;
        unfocused-split-opacity = 0.50;
        cursor-style = "block";
        cursor-style-blink = false;
        cursor-color = theme.palette.terminalAccent;
        cursor-text = theme.palette.terminalBackground;
        scrollback-limit = 104857600;
        confirm-close-surface = true;
        copy-on-select = "clipboard";
        macos-option-as-alt = true;
        window-save-state = "never";
        window-inherit-working-directory = true;
        mouse-hide-while-typing = true;
        quick-terminal-position = "center";
        quick-terminal-screen = "mouse";
        quick-terminal-size = "100%,100%";
        quick-terminal-animation-duration = 0;
        quick-terminal-autohide = false;
        quick-terminal-keyboard-interactivity = "exclusive";
        keybind = [
          "global:ctrl+`=toggle_quick_terminal"
          "shift+enter=text:\\x1b\\r"
          "super+t=unbind"
          "super+w=unbind"
          "super+h=unbind"
          "super+l=unbind"
          "super+r=unbind"
          "super+shift+t=unbind"
          "super+shift+w=unbind"
          "super+shift+h=unbind"
          "super+shift+l=unbind"
          "ctrl+h=unbind"
          "ctrl+j=unbind"
          "ctrl+k=unbind"
          "ctrl+l=unbind"
        ];
      };
    };
  };
}

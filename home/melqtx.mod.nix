{ config, ... }:

{
  flake.homeModules.melqtx = {
    imports = [
      config.flake.homeModules.fish
      config.flake.homeModules.starship
      config.flake.homeModules.ghostty
      config.flake.homeModules.zellij
      config.flake.homeModules.helix
      config.flake.homeModules.version-control
      config.flake.homeModules.language-tools
      config.flake.homeModules.emacs
      config.flake.homeModules.hammerspoon
    ];

    home.username = "melqtx";
    home.homeDirectory = "/Users/melqtx";
    home.stateVersion = "26.05";

    home.file."Library/Logs/Syncthing/.keep".text = "";
    home.file.".amethyst".text = builtins.toJSON {
      layouts = [
        "tall"
        "wide"
        "fullscreen"
        "column"
      ];

      mod1 = [ "option" ];
      mod2 = [
        "option"
        "shift"
      ];

      focus-screen-1 = {
        mod = "mod1";
        key = "1";
      };
      focus-screen-2 = {
        mod = "mod1";
        key = "2";
      };
      focus-screen-3 = {
        mod = "mod1";
        key = "3";
      };

      focus-ccw = {
        mod = "mod1";
        key = "j";
      };
      focus-cw = {
        mod = "mod1";
        key = "k";
      };
      focus-main = {
        mod = "mod1";
        key = "m";
      };

      swap-ccw = {
        mod = "mod2";
        key = "j";
      };
      swap-cw = {
        mod = "mod2";
        key = "k";
      };
      swap-main = {
        mod = "mod2";
        key = "m";
      };

      shrink-main = {
        mod = "mod1";
        key = "h";
      };
      expand-main = {
        mod = "mod1";
        key = "l";
      };
      increase-main = {
        mod = "mod1";
        key = ",";
      };
      decrease-main = {
        mod = "mod1";
        key = ".";
      };

      cycle-layout = {
        mod = "mod1";
        key = "space";
      };
      select-tall-layout = {
        mod = "mod1";
        key = "a";
      };
      select-wide-layout = {
        mod = "mod1";
        key = "s";
      };
      select-column-layout = {
        mod = "mod1";
        key = "d";
      };
      select-fullscreen-layout = {
        mod = "mod1";
        key = "f";
      };
      toggle-float = {
        mod = "mod1";
        key = "t";
      };

      throw-space-1 = {
        mod = "mod2";
        key = "1";
      };
      throw-space-2 = {
        mod = "mod2";
        key = "2";
      };
      throw-space-3 = {
        mod = "mod2";
        key = "3";
      };

      relaunch-amethyst = {
        mod = "mod2";
        key = "r";
      };
      reevaluate-windows = {
        mod = "mod1";
        key = "z";
      };

      window-margins = true;
      window-margin-size = 5;
      smart-window-margins = true;
      mouse-follows-focus = true;
      focus-follows-mouse = false;

      floating = [
        "com.apple.systempreferences"
        "com.apple.Calculator"
        "com.apple.Preview"
      ];

      enables-layout-hud = true;
      enables-layout-hud-on-space-change = true;
      enables-window-count-hud = false;
    };

    programs.home-manager.enable = true;
    services.syncthing.enable = true;
  };
}

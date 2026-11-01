{ config, lib, ... }:

let
  inherit (lib.options) mkOption;
  inherit (lib.types)
    ints
    str
    submodule
    ;
in
{
  options.profile = mkOption {
    default = { };
    type = submodule {
      options = {
        username = mkOption {
          type = str;
          default = "melqtx";
        };
        name = mkOption {
          type = str;
          default = config.profile.username;
        };
        email = mkOption {
          type = str;
          default = "melqtx@proton.me";
        };
        homeDirectory = mkOption {
          type = str;
          default = "/Users/${config.profile.username}";
        };
      };
    };
  };

  options.theme = mkOption {
    default = { };
    type = submodule {
      options = {
        terminalFont = mkOption {
          type = str;
          default = "FiraCode Nerd Font Mono";
        };
        editorFont = mkOption {
          type = str;
          default = "JetBrainsMono Nerd Font";
        };
        fontSize = mkOption {
          type = ints.positive;
          default = 15;
        };
        palette = mkOption {
          default = { };
          type = submodule {
            options =
              lib.attrsets.mapAttrs
                (
                  _: default:
                  mkOption {
                    type = lib.types.strMatching "#[0-9a-fA-F]{6}";
                    inherit default;
                  }
                )
                {
                  background = "#101010";
                  foreground = "#ffffff";
                  black = "#101010";
                  red = "#f5a191";
                  green = "#90b99f";
                  yellow = "#e6b99d";
                  blue = "#aca1cf";
                  magenta = "#e29eca";
                  cyan = "#ea83a5";
                  white = "#a0a0a0";
                  accent = "#ffc799";
                  selection = "#988049";
                  highlight = "#181818";
                  muted = "#7e7e7e";
                  border = "#282828";
                  modeline = "#1c1c1c";
                  terminalBackground = "#101010";
                  terminalForeground = "#ffffff";
                  terminalSurface = "#1c1c1c";
                  terminalMuted = "#a0a0a0";
                  terminalAccent = "#ffc799";
                  terminalBorder = "#988049";
                };
          };
        };
      };
    };
  };
}

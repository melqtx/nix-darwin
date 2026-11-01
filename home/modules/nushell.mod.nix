{ ... }:

{
  flake.homeModules.nushell =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      programs.nushell = {
        enable = true;
        loadSessionVariables = false;
        configDir = "${config.home.homeDirectory}/Library/Application Support/nushell";
        settings = {
          show_banner = false;
          buffer_editor = config.home.sessionVariables.EDITOR;
        };
        environmentVariables = {
          inherit (config.home.sessionVariables)
            EDITOR
            VISUAL
            NH_FLAKE
            RUST_SRC_PATH
            ;
        };
        extraConfig = ''
          $env.PATH = (${
            lib.hm.nushell.toNushell { } [
              "${config.home.profileDirectory}/bin"
              "/run/current-system/sw/bin"
              "${config.home.homeDirectory}/.local/bin"
              "${config.home.homeDirectory}/.cargo/bin"
              "${config.home.homeDirectory}/go/bin"
              "/opt/homebrew/bin"
              "/opt/homebrew/sbin"
            ]
          } | append $env.PATH | uniq)
        '';
        shellAliases = {
          v = lib.meta.getExe pkgs.helix;
          nv = lib.meta.getExe config.programs.neovim.finalPackage;
        };
      };
    };
}

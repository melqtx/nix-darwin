{ ... }:

{
  flake.homeModules.tooling =
    { lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe;
    in
    {
      home.packages = [
        pkgs.nix-index
        pkgs.typos
      ];

      home.file.".hushlogin".text = "";

      # Preserve OrbStack's generated host definition while making the rest
      # of the SSH client configuration declarative.
      home.file.".ssh/config".force = true;

      home.sessionVariables = {
        LESS = "--quit-if-one-screen --quit-on-intr --ignore-case --incsearch --LONG-PROMPT --no-edit-warn --chop-long-lines --HILITE-UNREAD --tilde --RAW-CONTROL-CHARS";
        MANPAGER = "sh -c 'col -bx | ${getExe pkgs.bat} --language man --plain --color always'";
        MANROFFOPT = "-c";
        RIPGREP_CONFIG_PATH = "$HOME/.config/ripgrep/config";
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = [ "~/.orbstack/ssh/config" ];

        settings."*" = {
          AddKeysToAgent = "no";
          Compression = false;
          ControlMaster = "auto";
          ControlPath = "~/.ssh/cm-%C";
          ControlPersist = "60m";
          ForwardAgent = false;
          ServerAliveCountMax = 3;
          ServerAliveInterval = 30;
          SetEnv.COLORTERM = "truecolor";
        };
      };

      # macOS supplies its own man implementation; there is no Home Manager
      # man package whose caches need generating.
      programs.man.generateCaches = false;

      xdg.configFile."ripgrep/config".text = ''
        --line-number
        --smart-case
      '';
    };
}

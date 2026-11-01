{ ... }:

{
  flake.homeModules.tooling =
    { lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe;
      inherit (lib.lists) singleton;
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
      };

      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        includes = singleton "~/.orbstack/ssh/config";

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

      programs = {
        broot = {
          enable = true;
          settings.modal = true;
        };
        yazi = {
          enable = true;
          shellWrapperName = "yy";
        };
        carapace.enable = true;
        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };
        fzf = {
          enable = true;
          defaultCommand = "${getExe pkgs.fd} --type f --hidden --exclude .git";
          fileWidget.command = "${getExe pkgs.fd} --type f --hidden --exclude .git";
          changeDirWidget.command = "${getExe pkgs.fd} --type d --hidden --exclude .git";
          defaultOptions = [
            "--height=40%"
            "--layout=reverse"
            "--border=rounded"
          ];
          # Atuin owns Ctrl+R; retain fzf's file/directory bindings.
          historyWidget.fish.command = "";
          historyWidget.nushell.command = "";
        };
        ripgrep = {
          enable = true;
          arguments = [
            "--line-number"
            "--smart-case"
          ];
        };
        zoxide.enable = true;
      };
    };
}

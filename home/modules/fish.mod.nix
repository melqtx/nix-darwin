{ ... }:

{
  flake.homeModules.fish =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.meta) getExe getExe';

      bottom = getExe pkgs.bottom;
      clear = getExe' pkgs.ncurses "clear";
      emacsclient = getExe' config.programs.doom-emacs.finalEmacsPackage "emacsclient";
      eza = getExe pkgs.eza;
      fish = getExe config.programs.fish.package;
      fnm = getExe pkgs.fnm;
      git = getExe pkgs.git;
      helix = getExe pkgs.helix;
      jj = getExe pkgs.jujutsu;
      neovim = getExe config.programs.neovim.finalPackage;
      xh = getExe pkgs.xh;
      zoxide = getExe config.programs.zoxide.package;
    in
    {
      home.sessionVariables = {
        EDITOR = helix;
        VISUAL = config.home.sessionVariables.EDITOR;
        NH_FLAKE = "${config.home.homeDirectory}/dots";
      };

      programs.fish = {
        enable = true;

        shellInit = /* fish */ ''
          # --path keeps this out of the universal fish_user_paths variable so
          # the order is recomputed every shell; each line prepends, so later
          # lines win. Keep Home Manager ahead of system Nix and Homebrew.
          fish_add_path --move --path /opt/homebrew/sbin
          fish_add_path --move --path /opt/homebrew/bin
          fish_add_path --move --path ~/.local/bin
          fish_add_path --move --path ~/go/bin
          fish_add_path --move --path ~/.cargo/bin
          fish_add_path --move --path /run/current-system/sw/bin
          fish_add_path --move --path ${config.home.profileDirectory}/bin
        '';

        interactiveShellInit = /* fish */ ''
          set --global --export GPG_TTY (tty)
          ${fnm} env --use-on-cd | source
        '';

        functions = {
          fish_greeting = "";

          battle = /* fish */ ''
            if not set --query REX_SESSION
              echo "Open a Rex terminal first, then run battle." >&2
              return 1
            end
            rex do battle cwd=${config.home.homeDirectory}/Documents/code
          '';

          battlestation = /* fish */ ''
            battle
          '';

          # MAS installs require interactive root and sometimes Apple Account
          # authentication, so keep them out of automatic Darwin activation.
          install-mas-apps = /* fish */ ''
            /opt/homebrew/bin/mas get 310633997 408981434 6745342698
          '';

          mc = /* fish */ ''
            command mkdir -p $argv[1]; and builtin cd $argv[1]
          '';

          mcg = /* fish */ ''
            mc $argv[1]; and ${jj} git init
          '';

          # Create a native Rex project session without nesting a multiplexer.
          rx = /* fish */ ''
            set --local root $PWD
            set --local project_root (${jj} --ignore-working-copy root 2>/dev/null)
            if test -z "$project_root"
              set project_root (${git} -C "$PWD" rev-parse --show-toplevel 2>/dev/null)
            end
            if test -n "$project_root"
              set root $project_root
            end

            set --local session
            if test (count $argv) -gt 0
              set session $argv[1]
            else
              set session "project-"(string escape --style=var -- "$root")
            end

            rex new "$session" --cwd "$root"
          '';

          realwhich = /* fish */ ''
            readlink -f (command --search $argv[1])
          '';
        };

        shellAliases = {
          zi = "${zoxide} query --interactive";

          # mtr-packet needs raw sockets; no setuid wrappers on nix-darwin
          mtr = "sudo ${getExe pkgs.mtr}";

          # nixpkgs peaclock links GNU libstdc++, which only knows the C
          # locale on darwin and aborts on en_IN.UTF-8
          peaclock = "env LC_ALL=C ${getExe pkgs.peaclock}";

          ja = "${jj} file track";
          ga = "${jj} file track";

          lg = "${jj} log";
          log = "${config.home.homeDirectory}/Documents/code/github/1337/bin/log";

          ls = "${eza} --no-quotes --icons --group-directories-first";
          l = "${eza} --no-quotes --all --icons --group-directories-first --sort=date";
          ll = "${eza} --no-quotes --all --long --icons --group-directories-first --sort=name";
          la = "${eza} --no-quotes --all --long --git --icons --group-directories-first --sort=date";
          lt = "${eza} --no-quotes --all --tree --icons --group-directories-first";
          lr = "${eza} --no-quotes --recurse --icons --group-directories-first";

          top = bottom;
          btm = bottom;
          http = xh;

          cls = clear;
          vim = neovim;
          nvim = neovim;
          nv = neovim;
          v = helix;
          hx = helix;

          # Keep terminal Emacs compatible with the daemon's terminfo.
          emacs = "TERM=xterm-256color ${emacsclient} --tty --alternate-editor=''";
          e = "TERM=xterm-256color ${emacsclient} --tty --alternate-editor=''";
          eg = "${emacsclient} --create-frame --no-wait --alternate-editor=''";
          tree = "${eza} --no-quotes --tree";
          dots = "cd ${config.home.sessionVariables.NH_FLAKE}";
          inherit fish;
        };
      };
    };
}

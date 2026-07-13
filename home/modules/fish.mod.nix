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

      atuin = getExe pkgs.atuin;
      bat = getExe pkgs.bat;
      bottom = getExe pkgs.bottom;
      btop = getExe pkgs.btop;
      carapace = getExe pkgs.carapace;
      clear = getExe' pkgs.ncurses "clear";
      delta = getExe pkgs.delta;
      direnv = getExe pkgs.direnv;
      dust = getExe pkgs.dust;
      emacsclient = getExe' pkgs.emacs30 "emacsclient";
      eza = getExe pkgs.eza;
      fd = getExe pkgs.fd;
      fish = getExe pkgs.fish;
      fnm = getExe pkgs.fnm;
      fzf = getExe pkgs.fzf;
      helix = getExe pkgs.helix;
      jj = getExe pkgs.jujutsu;
      neovim = getExe pkgs.neovim;
      nh = getExe pkgs.nh;
      procs = getExe pkgs.procs;
      ripgrep = getExe pkgs.ripgrep;
      sd = getExe pkgs.sd;
      starship = getExe pkgs.starship;
      xh = getExe pkgs.xh;
      yazi = getExe pkgs.yazi;
      zellij = getExe pkgs.zellij;
      zoxide = getExe pkgs.zoxide;
    in
    {
      home.sessionVariables = {
        EDITOR = helix;
        VISUAL = helix;
        NH_FLAKE = "${config.home.homeDirectory}/dots";
      };

      programs.fish = {
        enable = true;

        shellInit = /* fish */ ''
          # --path keeps this out of the universal fish_user_paths variable so
          # the order is recomputed every shell; each line prepends, so later
          # lines win. Nix must beat homebrew.
          fish_add_path --move --path /opt/homebrew/sbin
          fish_add_path --move --path /opt/homebrew/bin
          fish_add_path --move --path /run/current-system/sw/bin
          fish_add_path --move --path ~/.local/bin
          fish_add_path --move --path ~/go/bin
          fish_add_path --move --path ~/.config/emacs/bin

          set --global --export GPG_TTY (tty)
        '';

        interactiveShellInit = /* fish */ ''
          ${starship} init fish | source
          ${zoxide} init fish | source
          ${atuin} init fish | source
          ${direnv} hook fish | source
          ${fzf} --fish | source
          ${fnm} env --use-on-cd | source
          ${carapace} _carapace fish | source
        '';

        functions = {
          # elenapan's bin/colorpanes (GekkoP's "panes" art) in gruvbox,
          # hardcoded so it doesn't depend on the terminal palette
          fish_greeting = /* fish */ ''
            set -l body cc241d 98971a d79921 458588 b16286 689d6a d65d0e
            set -l edge fb4934 b8bb26 fabd2f 83a598 d3869b 8ec07c fe8019

            echo
            for row in 1 2 3
                echo -n ' '
                for i in (seq 7)
                    set_color $body[$i]
                    echo -n '███'
                    set_color $edge[$i]
                    test $row -eq 1; and echo -n '▄'; or echo -n '█'
                    echo -n '  '
                end
                set_color normal
                echo
            end
            echo -n ' '
            for i in (seq 7)
                set_color $edge[$i]
                echo -n ' ▀▀▀  '
            end
            set_color normal
            echo
            echo
          '';

          battle = /* fish */ ''
            builtin cd ${config.home.homeDirectory}/code
            ${zellij} --layout battlestation
          '';

          battlestation = /* fish */ ''
            battle
          '';

          # MAS installs require interactive root and sometimes Apple Account
          # authentication, so keep them out of automatic Darwin activation.
          install-mas-apps = /* fish */ ''
            /opt/homebrew/bin/mas get 310633997 408981434 6745342698
          '';
        };

        shellAliases = {
          zi = "${zoxide} query --interactive";
          yy = yazi;

          js = "${jj} status";
          ja = "${jj} file track";
          ga = "${jj} file track";
          jc = "${jj} commit";
          jd = "${jj} diff";
          jl = "${jj} log";
          jn = "${jj} new";
          jsh = "${jj} show";
          ju = "${jj} undo";

          lg = "${jj} log";
          log = "${config.home.homeDirectory}/Documents/code/github/1337/bin/log";

          ls = "${eza} --no-quotes --icons --group-directories-first";
          l = "${eza} --no-quotes --all --icons --group-directories-first --sort=date";
          ll = "${eza} --no-quotes --all --long --icons --group-directories-first --sort=name";
          la = "${eza} --no-quotes --all --long --git --icons --group-directories-first --sort=date";
          lt = "${eza} --no-quotes --all --tree --icons --group-directories-first";
          lr = "${eza} --no-quotes --recurse --icons --group-directories-first";

          cat = bat;
          grep = ripgrep;
          find = fd;
          du = dust;
          ps = procs;
          top = btop;
          btm = bottom;
          http = xh;
          diff = delta;
          sed = sd;

          cls = clear;
          vim = neovim;
          nvim = neovim;
          nv = neovim;
          v = helix;
          hx = helix;

          # ghostty's xterm-ghostty terminfo is unknown to the emacs daemon
          emacs = "TERM=xterm-256color ${emacsclient} --tty --alternate-editor=''";
          e = "TERM=xterm-256color ${emacsclient} --tty --alternate-editor=''";
          eg = "${emacsclient} --create-frame --no-wait --alternate-editor=''";
          tree = "${eza} --no-quotes --tree";
          # Use an explicit path flake so newly created modules work before
          # their first commit; Git flake snapshots omit untracked files.
          rebuild = "${nh} darwin switch path:${config.home.homeDirectory}/dots";
          dots = "cd ~/dots";
          zj = zellij;
          inherit fish;
        };
      };
    };
}

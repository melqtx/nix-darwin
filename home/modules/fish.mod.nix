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
          fish_add_path /run/current-system/sw/bin
          fish_add_path /opt/homebrew/bin
          fish_add_path /opt/homebrew/sbin
          fish_add_path ~/.local/bin
          fish_add_path ~/go/bin
          fish_add_path ~/.config/emacs/bin

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
          battle = /* fish */ ''
            builtin cd ${config.home.homeDirectory}/code
            ${zellij} --layout battlestation
          '';

          battlestation = /* fish */ ''
            battle
          '';
        };

        shellAliases = {
          cd = "z";
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
          rebuild = "${nh} darwin switch";
          dots = "cd ~/dots";
          zj = zellij;
          fish = fish;
        };
      };
    };
}

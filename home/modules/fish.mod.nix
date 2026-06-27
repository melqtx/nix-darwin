{ ... }:

{
  flake.homeModules.fish =
    { lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe getExe';

      atuin = getExe pkgs.atuin;
      bat = getExe pkgs.bat;
      bottom = getExe pkgs.bottom;
      btop = getExe pkgs.btop;
      clear = getExe' pkgs.ncurses "clear";
      delta = getExe pkgs.delta;
      direnv = getExe pkgs.direnv;
      dust = getExe pkgs.dust;
      eza = getExe pkgs.eza;
      fd = getExe pkgs.fd;
      fish = getExe pkgs.fish;
      fnm = getExe pkgs.fnm;
      fzf = getExe pkgs.fzf;
      helix = getExe pkgs.helix;
      jj = getExe pkgs.jujutsu;
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
      };

      programs.fish = {
        enable = true;

        shellInit = /* fish */ ''
          fish_add_path /run/current-system/sw/bin
          fish_add_path /opt/homebrew/bin
          fish_add_path /opt/homebrew/sbin
          fish_add_path ~/.local/bin

          set --global --export GPG_TTY (tty)
        '';

        interactiveShellInit = /* fish */ ''
          ${starship} init fish | source
          ${zoxide} init fish | source
          ${atuin} init fish | source
          ${direnv} hook fish | source
          ${fzf} --fish | source
          ${fnm} env --use-on-cd | source
        '';

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

          ls = "${eza} --icons --group-directories-first";
          l = "${eza} --all --icons --group-directories-first --sort=date";
          ll = "${eza} --all --long --icons --group-directories-first --sort=name";
          la = "${eza} --all --long --git --icons --group-directories-first --sort=date";
          lt = "${eza} --all --tree --icons --group-directories-first";
          lr = "${eza} --recurse --icons --group-directories-first";

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
          vim = helix;
          v = helix;
          hx = helix;
          tree = "${eza} --tree";
          rebuild = "/usr/bin/sudo /run/current-system/sw/bin/darwin-rebuild switch --flake ~/dots#prometheus";
          dots = "cd ~/dots";
          zj = zellij;
          fish = fish;
        };
      };
    };
}

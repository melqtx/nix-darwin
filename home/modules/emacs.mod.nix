{ ... }:

{
  flake.homeModules.emacs =
    { pkgs, ... }:
    {
      home.file."Documents/org/roam/.keep".text = "";
      home.file."Documents/org/roam/main/.keep".text = "";
      home.file."Documents/org/roam/reference/.keep".text = "";
      home.file."Documents/org/roam/articles/.keep".text = "";

      programs.doom-emacs = {
        enable = true;
        doomDir = ./emacs/doom.d;
        emacs = pkgs.emacs30;

        # Determinate Nix is new enough to hit fetchGit's intermittent
        # "Cannot find Git revision" failure. Upstream recommends fetchTree
        # as the more efficient workaround.
        experimentalFetchTree = true;
      };

      # Unstraightened supplies the wrapped package to the daemon.
      services.emacs.enable = true;
    };
}

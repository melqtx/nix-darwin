{ ... }:

{
  flake.homeModules.emacs =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.graphviz
        pkgs.pngpaste
      ];

      home.file."Documents/org/roam/.keep".text = "";
      home.file."Documents/org/roam/main/.keep".text = "";
      home.file."Documents/org/roam/reference/.keep".text = "";
      home.file."Documents/org/roam/articles/.keep".text = "";
      home.file."Documents/org/roam/university/.keep".text = "";
      home.file."Documents/org/roam/university/courses/.keep".text = "";
      home.file."Documents/org/roam/university/lectures/.keep".text = "";

      programs.doom-emacs = {
        enable = true;
        doomDir = ./emacs/doom.d;
        inherit (pkgs) emacs;

        # Determinate Nix is new enough to hit fetchGit's intermittent
        # "Cannot find Git revision" failure. Upstream recommends fetchTree
        # as the more efficient workaround.
        experimentalFetchTree = true;
      };

      # Unstraightened supplies the wrapped package to the daemon.
      services.emacs.enable = true;
    };
}

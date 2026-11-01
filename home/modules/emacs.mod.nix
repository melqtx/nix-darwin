{ config, inputs, ... }:

let
  inherit (config) profile theme;
in
{
  flake.homeModules.emacs =
    { lib, pkgs, ... }:
    let
      inherit (lib.lists) singleton;
      inherit (lib.strings) toJSON;
      doomConfig = pkgs.replaceVars ./emacs/doom.d/config.el {
        userFullName = toJSON profile.name;
        userEmail = toJSON profile.email;
        editorFont = toJSON theme.editorFont;
        fontSize = toString theme.fontSize;
        foreground = toJSON theme.palette.foreground;
        background = toJSON theme.palette.background;
        accent = toJSON theme.palette.accent;
        selection = toJSON theme.palette.selection;
        highlight = toJSON theme.palette.highlight;
        muted = toJSON theme.palette.muted;
        border = toJSON theme.palette.border;
        modeline = toJSON theme.palette.modeline;
      };
    in
    {
      imports = singleton inputs.nix-doom-emacs-unstraightened.homeModule;

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
        doomDir = pkgs.linkFarm "doom-config" [
          {
            name = "init.el";
            path = ./emacs/doom.d/init.el;
          }
          {
            name = "packages.el";
            path = ./emacs/doom.d/packages.el;
          }
          {
            name = "config.el";
            path = doomConfig;
          }
        ];
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

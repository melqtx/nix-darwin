{ ... }:

{
  flake.homeModules.version-control =
    { pkgs, ... }:
    let
      jjConfig = (pkgs.formats.toml { }).generate "jj-config.toml" {
        user = {
          name = "melqtx";
          email = "melqtx@proton.me";
        };

        aliases = {
          a = [
            "file"
            "track"
          ];
          c = [ "commit" ];
          d = [ "diff" ];
          e = [ "edit" ];
          l = [ "log" ];
          n = [ "new" ];
          s = [ "status" ];
          sh = [ "show" ];
          u = [ "undo" ];
        };

        ui = {
          default-command = "status";
          diff-editor = ":builtin";
          pager = "delta";
        };
      };
    in
    {
      home.packages = [
        pkgs.jujutsu
        pkgs.delta
        pkgs.gh
      ];

      xdg.configFile."jj/config.toml".source = jjConfig;
    };
}

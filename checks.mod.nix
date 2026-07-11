{ inputs, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      checks.lint =
        pkgs.runCommandLocal "lint"
          {
            nativeBuildInputs = [
              pkgs.statix
              pkgs.deadnix
              pkgs.nixfmt
            ];
          }
          ''
            cd ${inputs.self}
            statix check .
            deadnix --fail .
            find . -name '*.nix' -exec nixfmt --check {} +
            touch $out
          '';
    };
}

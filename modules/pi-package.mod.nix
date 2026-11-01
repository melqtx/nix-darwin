{ ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      packages.pi-coding-agent = pkgs.callPackage (
        {
          buildNpmPackage,
          fetchurl,
          jq,
          lib,
        }:
        let
          inherit (lib.meta) getExe;
        in
        buildNpmPackage (finalAttrs: {
          pname = "pi-coding-agent";
          version = "0.84.4";

          src = fetchurl {
            url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${finalAttrs.version}.tgz";
            hash = "sha256-W852bRnDzroY8/uq2RxEnJ+dc5gfnjQA7O+TIAbwaWg=";
          };

          # The published shrinkwrap omits sibling-package integrity and devDependencies.
          postPatch = /* bash */ ''
            ${getExe jq} '
              .packages["node_modules/@earendil-works/pi-agent-core"].integrity = "sha512-HyUnjaOXj6oN/6SNcr8A1J/ElRQA50FtIE0XUTSKAQVqmdlb9qdojOyUQwF/jULE5+yOEtGuVgi/N1RnBiNG+g==" |
              .packages["node_modules/@earendil-works/pi-ai"].integrity = "sha512-AClAZxf5+c4RRu44NJPS6wyQy+Nmq+Mzyyrdvm4ZVMNuixelO02RZX4G4Aq1F145Yzp43wnM5S+hLlSI7ypfVw==" |
              .packages["node_modules/@earendil-works/pi-client"].integrity = "sha512-q398WY/3ZQHTizk7IKxApzqFV0xt4yM9LkSkwyqeLK5Bj5RwRjOWxESt26z4LgNp4O+8hqhqFPf/8fj4H5rE4A==" |
              .packages["node_modules/@earendil-works/pi-protocol"].integrity = "sha512-acyE9ozxkMiWiz/xyWpU0O9vwnYv0hyG889Vniv6Sg9c9zfsX+8MePnDNphBacY2Fvm1rxdsGmiVDSZl9yuDFA==" |
              .packages["node_modules/@earendil-works/pi-telemetry"].integrity = "sha512-8e2CuxM+ht+hedQXTZmi5JVl6/xDK9RpSDL2+MbITevKYQhMZ/z6lJOTFgox3HQyGxO8mOZEtYGVeQNaD4OzqA==" |
              .packages["node_modules/@earendil-works/pi-tui"].integrity = "sha512-nPUnwDkLtupPXnZQYrCwPFcuTydCDqTY6ZbFqhsL4S4kVq0AT418kPa/6uXwtaCD+MjBNBltb7ScTYX65yeE1w=="
            ' npm-shrinkwrap.json > package-lock.json
            cp package-lock.json npm-shrinkwrap.json

            ${getExe jq} 'del(.devDependencies)' package.json > package.json.tmp
            mv package.json.tmp package.json
          '';

          npmDepsHash = "sha256-qehCRHtAPu1TS6zDPA5UgJ1ScUuRX3CmZhRoIQd3HM0=";
          dontNpmBuild = true;

          meta.mainProgram = "pi";
        })
      ) { };
    };
}

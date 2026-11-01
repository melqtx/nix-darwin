{ self, ... }:

{
  flake.darwinModules.obs =
    { lib, ... }:
    let
      inherit (lib.lists) singleton;
    in
    {
      imports = singleton self.darwinModules.homebrew;
      homebrew.casks = singleton "obs";
    };
}

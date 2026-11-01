{ ... }:

{
  flake.homeModules.syncthing = {
    home.file."Library/Logs/Syncthing/.keep".text = "";

    services.syncthing.enable = true;
  };
}

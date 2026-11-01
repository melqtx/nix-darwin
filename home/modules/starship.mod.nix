{ ... }:

{
  flake.homeModules.starship =
    { ... }:
    {
      programs.starship = {
        enable = true;
        enableFishIntegration = true;

        settings = {
          format = "$directory$git_branch$nix_shell$python$line_break$character";

          character = {
            success_symbol = "[（✿ ◕ ᴗ◕\\)つ━━✫・*。](dimmed)";
            error_symbol = "[ Ψ\\(`_´ # \\)↝ ](red)";
            vimcmd_symbol = "[󰄛 ❮](subtext1)";
          };

          directory = {
            format = "";
            style = "bold green";
          };

          git_branch = {
            format = "  [ $branch]($style)";
            style = "yellow";
          };

          python = {
            format = " ";
            style = "bright-black";
          };

          nix_shell = {
            format = "  ";
            symbol = " ";
            style = "dimmed purple";
          };
        };
      };
    };
}

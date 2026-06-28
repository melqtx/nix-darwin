{ ... }:

{
  flake.homeModules.starship =
    { ... }:
    {
      programs.starship = {
        enable = true;
        enableFishIntegration = false;

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

          git_status = {
            format = "[[( [::](dimmed) $conflicted$untracked$modified$staged$renamed$deleted)](blue) ($ahead_behind$stashed)]($style)";
            style = "cyan";
            conflicted = " ";
            untracked = "󰰨 ";
            modified = "󰯲 ";
            staged = "󰰢 ";
            renamed = "󰰟 ";
            deleted = "󰯵 ";
            stashed = "≡";
          };

          git_state = {
            format = "\\(\\) ";
            style = "bright-black";
          };

          cmd_duration = {
            format = "[(   󱎫  took $duration\\n)]($style)";
            style = "dimmed";
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

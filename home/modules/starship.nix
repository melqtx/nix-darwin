{ ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = false;

    settings = {
      format = "$directory$git_branch$git_status$nix_shell$python$line_break$character";

      character = {
        success_symbol = "[（✿ ◕ ᴗ◕\\)つ━━✫・*。](dimmed)";
        error_symbol = "[ Ψ\\(`_´ # \\)↝ ](red)";
        vimcmd_symbol = "[󰄛 ❮](dimmed)";
      };

      directory = {
        format = "[$path]($style)";
        style = "bold green";
      };

      git_branch = {
        format = "  [ $branch]($style)";
        style = "yellow";
      };

      git_status = {
        format = "[ $conflicted$untracked$modified$staged$renamed$deleted]($style)";
        style = "cyan";
        conflicted = " ";
        untracked = "󰰨 ";
        modified = "󰯲 ";
        staged = "󰰢 ";
        renamed = "󰰟 ";
        deleted = "󰯵 ";
        stashed = "≡";
      };

      python = {
        format = "[$virtualenv]($style) ";
        style = "bright-black";
      };

      nix_shell = {
        format = " [$symbol$state( \\($name\\))]($style) ";
        symbol = " ";
        style = "dimmed purple";
      };
    };
  };
}

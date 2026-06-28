{ ... }:

{
  flake.homeModules.starship =
    { lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe;

      jj = getExe pkgs.jujutsu;
    in
    {
      programs.starship = {
        enable = true;
        enableFishIntegration = false;

        settings = {
          format = "$directory$git_branch$custom.jj$nix_shell$python$line_break$character";

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

          custom.jj = {
            command = "${jj} --ignore-working-copy log --no-graph --revisions @ --template 'change_id.short()'";
            when = "${jj} --ignore-working-copy root --quiet";
            format = "  [jj $output]($style)";
            style = "dimmed purple";
          };
        };
      };
    };
}

{ ... }:

{
  flake.homeModules.zed =
    { pkgs, ... }:
    let
      json = pkgs.formats.json { };

      settings = json.generate "zed-settings.json" {
        cli_default_open_behavior = "new_window";
        vim_mode = false;

        agent_servers."codex-acp".type = "registry";

        ui_font_size = 16;
        buffer_font_size = 15;
        theme = {
          mode = "system";
          light = "Ayu Light";
          dark = "Ayu Dark";
        };

        languages.Rust = {
          formatter = "language_server";
          format_on_save = "on";
          inlay_hints = {
            enabled = true;
            show_type_hints = true;
            show_parameter_hints = true;
            show_other_hints = true;
          };
        };

        lsp."rust-analyzer".initialization_options = {
          check.command = "clippy";
          inlayHints = {
            closureReturnTypeHints.enable = "with_block";
            lifetimeElisionHints = {
              enable = "skip_trivial";
              useParameterNames = true;
            };
          };
        };
      };

      tasks = json.generate "zed-tasks.json" [
        {
          label = "Rust: run";
          command = "cargo";
          args = [ "run" ];
          save = "all";
        }
        {
          label = "Rust: check workspace";
          command = "cargo";
          args = [
            "check"
            "--workspace"
            "--all-targets"
          ];
          save = "all";
          hide = "on_success";
        }
        {
          label = "Rust: test workspace";
          command = "cargo";
          args = [
            "test"
            "--workspace"
            "--all-targets"
          ];
          save = "all";
        }
        {
          label = "Rust: clippy (strict)";
          command = "cargo";
          args = [
            "clippy"
            "--workspace"
            "--all-targets"
            "--all-features"
            "--"
            "-D"
            "warnings"
          ];
          save = "all";
        }
        {
          label = "Rust: check formatting";
          command = "cargo";
          args = [
            "fmt"
            "--all"
            "--check"
          ];
          save = "all";
          hide = "on_success";
        }
        {
          label = "Rust: open docs";
          command = "cargo";
          args = [
            "doc"
            "--open"
          ];
          save = "all";
        }
      ];
    in
    {
      # Take over the settings file that Zed creates on first launch.
      xdg.configFile."zed/settings.json" = {
        force = true;
        source = settings;
      };
      xdg.configFile."zed/tasks.json".source = tasks;
    };
}

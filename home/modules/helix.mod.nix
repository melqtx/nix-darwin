{ inputs, ... }:

{
  flake.homeModules.helix =
    { lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe;
      inherit (inputs.self.packages.${pkgs.stdenv.hostPlatform.system})
        helix-darwin-app
        hx-github-permalink
        ;
      language = name: formatter: servers: {
        inherit name formatter;
        auto-format = true;
        language-servers = servers;
      };
      prettier =
        name: parser: servers:
        language name {
          command = "prettier";
          args = [
            "--parser"
            parser
          ];
        } servers;
    in
    {
      home.packages = [ helix-darwin-app ];

      programs.helix = {
        enable = true;
        defaultEditor = false;
        settings = {
          theme = "catppuccin_mocha";
          editor = {
            auto-completion = true;
            bufferline = "multiple";
            completion-trigger-len = 2;
            line-number = "absolute";
            mouse = false;
            auto-save.focus-lost = true;
            cursor-shape = {
              insert = "bar";
              normal = "block";
              select = "underline";
            };
            file-picker.hidden = false;
            inline-diagnostics = {
              cursor-line = "warning";
              other-lines = "error";
            };
            lsp.display-inlay-hints = true;
            soft-wrap.enable = true;
            statusline = {
              center = [ "file-name" ];
              left = [
                "mode"
                "spinner"
              ];
              right = [
                "diagnostics"
                "selections"
                "position"
                "file-encoding"
                "file-line-ending"
                "file-type"
              ];
              separator = "│";
              mode = {
                insert = "INSERT";
                normal = "NORMAL";
                select = "SELECT";
              };
            };
          };
          keys = {
            insert.esc = [
              "collapse_selection"
              "normal_mode"
            ];
            normal = {
              w = [
                "move_next_word_start"
                "collapse_selection"
              ];
              e = [
                "move_next_word_end"
                "collapse_selection"
              ];
              b = [
                "move_prev_word_start"
                "collapse_selection"
              ];
              h = [
                "move_char_left"
                "collapse_selection"
              ];
              j = [
                "move_visual_line_down"
                "collapse_selection"
              ];
              k = [
                "move_visual_line_up"
                "collapse_selection"
              ];
              l = [
                "move_char_right"
                "collapse_selection"
              ];
              space.y = {
                p = [ ":sh printf '%s' %{buffer_name} | /usr/bin/pbcopy" ];
                g = [ ":sh ${getExe hx-github-permalink} %{buffer_name} %{cursor_line} | /usr/bin/pbcopy" ];
              };
            };
          };
        };
        languages = {
          language-server = {
            nixd.command = "nixd";
            gopls.config.staticcheck = true;
            rust-analyzer.config.check.command = "clippy";
            ty = {
              command = "ty";
              args = [ "server" ];
            };
            lean = {
              command = "lake";
              args = [ "serve" ];
            };
          };
          language = [
            (language "nix" { command = "nixfmt"; } [ "nixd" ])
            (
              (language "rust" { command = "rustfmt"; } [ "rust-analyzer" ])
              // {
                debugger = {
                  name = "lldb-dap";
                  transport = "stdio";
                  command = "lldb-dap";
                  templates = [
                    {
                      name = "binary";
                      request = "launch";
                      completion = [
                        {
                          name = "binary";
                          completion = "filename";
                        }
                      ];
                      args.program = "{0}";
                    }
                  ];
                };
              }
            )
            (language "go" { command = "gofumpt"; } [ "gopls" ])
            (language "python" {
              command = "ruff";
              args = [
                "format"
                "-"
              ];
            } [ "ty" ])
            (prettier "typescript" "typescript" [ "typescript-language-server" ])
            (prettier "javascript" "babel" [ "typescript-language-server" ])
            (language "haskell" { command = "fourmolu"; } [ "haskell-language-server" ])
            {
              name = "lean";
              roots = [
                "lakefile.lean"
                "lakefile.toml"
                "lean-toolchain"
              ];
              language-servers = [ "lean" ];
              auto-format = false;
            }
            (language "zig" {
              command = "zig";
              args = [
                "fmt"
                "--stdin"
              ];
            } [ "zls" ])
            (language "java" {
              command = "google-java-format";
              args = [ "-" ];
            } [ "jdtls" ])
            (prettier "json" "json" [ "vscode-json-language-server" ])
            (prettier "html" "html" [ "vscode-html-language-server" ])
            (prettier "css" "css" [ "vscode-css-language-server" ])
            (prettier "yaml" "yaml" [ "yaml-language-server" ])
          ];
        };
      };
    };
}

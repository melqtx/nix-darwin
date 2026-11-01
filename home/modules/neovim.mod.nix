{ ... }:

{
  flake.homeModules.neovim =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      configRoot = ./neovim/config;
      restore =
        update:
        pkgs.writeShellApplication {
          name = if update then "nvim-update" else "nvim-setup";
          runtimeInputs = [
            pkgs.python3
            pkgs.git
            pkgs.stdenv.cc
          ];
          text = ''
            export CC=${lib.meta.getExe pkgs.stdenv.cc}
            exec python3 ${./neovim/setup.py} \
              --source ${./neovim} \
              --nvim ${lib.meta.getExe config.programs.neovim.finalPackage} ${lib.optionalString update "--update"} "$@"
          '';
        };
    in
    {
      programs.neovim = {
        enable = true;
        extraPackages = [
          pkgs.tree-sitter
          pkgs.stylua
        ];
        initLua = builtins.readFile (configRoot + /init.lua) + ''

          vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("DotsLspStartup", { clear = true }),
            once = true,
            callback = function()
              require("dots.lsp")
            end,
          })
        '';
      };

      home.packages = [
        (restore false)
        (restore true)
      ];
      home.activation.restoreNeovim = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        $DRY_RUN_CMD ${lib.meta.getExe (restore false)}
      '';
      xdg.configFile =
        builtins.listToAttrs (
          map (
            file:
            lib.nameValuePair "nvim/${lib.removePrefix "${toString configRoot}/" (toString file)}" {
              source = file;
            }
          ) (lib.filter (file: file != configRoot + /init.lua) (lib.filesystem.listFilesRecursive configRoot))
        )
        // {
          "nvim/lua/dots/lsp.lua".source = ./neovim/lsp.lua;
        };
    };
}

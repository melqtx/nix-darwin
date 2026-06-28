{ ... }:

{
  flake.darwinModules.packages =
    { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.home-manager

        pkgs.fish
        pkgs.starship
        pkgs.zellij
        pkgs.helix
        pkgs.neovim

        pkgs.zoxide
        pkgs.atuin
        pkgs.direnv
        pkgs.nix-direnv
        pkgs.fzf
        pkgs.jujutsu
        pkgs.gh
        pkgs.delta

        pkgs.ripgrep
        pkgs.fd
        pkgs.ast-grep
        pkgs.uutils-coreutils-noprefix
        pkgs.uutils-findutils
        pkgs.uutils-diffutils

        pkgs.eza
        pkgs.bat
        pkgs.yazi
        pkgs.dua
        pkgs.dust
        pkgs.procs

        pkgs.jq
        pkgs.yq
        pkgs.gron
        pkgs.jnv
        pkgs.jless
        pkgs.miller

        pkgs.btop
        pkgs.bottom
        pkgs.bandwhich

        pkgs.tldr
        pkgs.llm
        pkgs.tokei
        pkgs.hyperfine
        pkgs.watchexec
        pkgs.sd
        pkgs.just
        pkgs.difftastic
        pkgs.hexyl
        pkgs.xh

        pkgs.go
        pkgs.nodejs_24
        pkgs.pnpm
        pkgs.bun
        pkgs.uv
        pkgs.fnm
        pkgs.openjdk
      ];
    };
}

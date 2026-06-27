{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    home-manager
    fish
    starship
    zoxide
    atuin
    direnv
    fzf

    git
    gh
    jj
    lazygit
    delta

    neovim
    ripgrep
    fd
    ast-grep

    eza
    bat
    tree
    yazi
    dua
    dust
    procs

    jq
    yq
    gron
    jless
    miller

    btop
    bottom
    bandwhich

    tldr
    tokei
    hyperfine
    watchexec
    sd
    just
    difftastic
    hexyl
    zellij

    go
    uv
    fnm
    openjdk
  ];
}

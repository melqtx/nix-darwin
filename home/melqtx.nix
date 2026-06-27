{ pkgs, ... }:

{
  home.username = "melqtx";
  home.homeDirectory = "/Users/melqtx";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;

    shellInit = ''
      fish_add_path /run/current-system/sw/bin
      fish_add_path /opt/homebrew/bin
      fish_add_path /opt/homebrew/sbin
      fish_add_path ~/.local/bin

      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx GPG_TTY (tty)
    '';

    interactiveShellInit = ''
      command -q starship; and starship init fish | source
      command -q zoxide; and zoxide init fish | source
      command -q atuin; and atuin init fish | source
      command -q direnv; and direnv hook fish | source
      command -q fzf; and fzf --fish | source
      command -q fnm; and fnm env --use-on-cd | source
    '';

    shellAliases = {
      cd = "z";
      zi = "zoxide query -i";
      yy = "yazi";

      gs = "git status";
      ga = "git add";
      gaa = "git add -A";
      gc = "git commit";
      gd = "git diff";
      gdc = "git diff --cached";
      gds = "git diff --staged";
      gl = "git log --oneline --graph --decorate";
      gch = "git checkout";
      gpl = "git pull origin main --no-rebase";
      lg = "lazygit";

      jjs = "jj status";
      jjl = "jj log";
      jjn = "jj new";
      jjd = "jj diff";

      ls = "eza --icons --group-directories-first";
      l = "eza -a --icons --group-directories-first --sort=date";
      ll = "eza -al --icons --group-directories-first --sort=name";
      la = "eza --git -ahl --icons --group-directories-first --sort=date";
      lt = "eza -aT --icons --group-directories-first";
      lr = "eza -R --icons --group-directories-first";

      cat = "bat";
      grep = "rg";
      find = "fd";
      du = "dust";
      ps = "procs";
      top = "btop";
      http = "xh";
      diff = "delta";
      sed = "sd";

      cls = "clear";
      vim = "nvim";
      v = "nvim";
      tree = "eza --tree";
    };
  };


 programs.git = {
  enable = true;

  settings = {
    user = {
      name = "melqtx";
      email = "melqtx@proton.me";
    };

    init.defaultBranch = "main";
    core.editor = "nvim";
    pull.rebase = false;
    fetch.prune = true;

    pager.diff = "delta";
    pager.log = "delta";
    pager.show = "delta";
  };
};

  programs.starship = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = false;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableFishIntegration = false;
  };
  home.file.".config/ghostty/config".text = ''
  font-family = Berkeley Mono
  font-size = 15

  background = 1e1e2e
  foreground = cdd6f4
  cursor-color = f5e0dc
  selection-background = 585b70
  selection-foreground = cdd6f4

  shell-integration = fish

  window-padding-x = 8
  window-padding-y = 8

  background-opacity = 0.95
  background-blur-radius = 20

  cursor-style = block
  cursor-style-blink = false

  confirm-close-surface = false

  copy-on-select = clipboard
  macos-option-as-alt = true

  window-save-state = always
  window-inherit-working-directory = true

  mouse-hide-while-typing = true
'';
}

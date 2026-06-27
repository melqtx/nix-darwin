{ ... }:

{
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
}

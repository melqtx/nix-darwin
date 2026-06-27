{ ... }:

{
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
}

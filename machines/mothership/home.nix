{ config, lib, pkgs, ... }: {
  devos.home = {
    name = "Cainã Costa";
    username = "cfcosta";
    email = "me@cfcosta.com";
    githubUser = "cfcosta";

    alacritty.enable = true;

    emacs = {
      enable = true;
      theme = "doom-ir-black";
    };

    vscode = {
      enable = true;
      vimMode = true;
    };

    git = { enable = true; };
  };
}

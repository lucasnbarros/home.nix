{ config, lib, pkgs, ... }:
with lib; {
  devos.home = {
    name = "Cainã Costa";
    username = "cfcosta";
    email = "me@cfcosta.com";
    githubUser = "cfcosta";

    alacritty = {
      enable = true;
      font.family = "Inconsolata";
    };

    gnome = {
      enable = true;
      darkTheme = true;
      keymaps = [ "us" "us+intl" ];
    };

    emacs = {
      enable = true;
      theme = "doom-moonlight";

      fonts.fixed = {
        family = "Inconsolata";
        size = "18";
      };

      fonts.variable = {
        family = "Inconsolata";
        size = "18";
      };
    };

    vscode = {
      enable = true;
      vimMode = true;
    };

    git = { enable = true; };
  };
}

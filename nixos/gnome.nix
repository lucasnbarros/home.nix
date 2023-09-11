{ lib, pkgs, config, ... }:
with lib;
let
  cfg = config.dusk.gnome;
  browsers = with pkgs; [
    (firefox.override { cfg = { enableGnomeExtensions = true; }; })
    nyxt
    brave
    microsoft-edge
  ];
in {
  options = { dusk.gnome.enable = mkEnableOption "gnome"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [
        adw-gtk3
        alacritty
        bitwarden
        discord
        element-desktop
        gitg
        meld
        obs-studio
        obsidian
        signal-desktop
        tdesktop

        # TODO: Find a way to install this only if wayland is not enabled
        xclip
      ] ++ browsers;

    hardware.opengl.enable = true;

    services.xserver = {
      enable = true;

      layout = "us";
      xkbVariant = "";

      displayManager.gdm = {
        enable = true;
        autoSuspend = false;
      };

      desktopManager.gnome.enable = true;

      libinput.enable = true;
    };

    services.avahi = {
      enable = true;

      publish = {
        enable = true;
        userServices = true;
      };

      nssmdns = true;
    };

    services.flatpak.enable = true;
    services.packagekit.enable = true;
  };
}
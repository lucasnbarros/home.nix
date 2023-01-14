{ lib, pkgs, config, ... }:
with lib;
let cfg = config.devos.gnome;
in {
  options = {
    devos.gnome.enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether or not to enable the gnome desktop environment
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      adw-gtk3
      alacritty
      bitwarden
      brave
      cawbird
      element-desktop
      (firefox.override { cfg = { enableGnomeExtensions = true; }; })
      gnomeExtensions.blur-my-shell
      gnomeExtensions.dash-to-dock
      gnomeExtensions.wifi-qrcode
      newsflash
      obs-studio
      obsidian
      rnote
      spot
      tdesktop
    ];

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

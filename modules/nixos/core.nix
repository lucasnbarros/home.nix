{ lib, pkgs, config, ... }:
with lib;
let cfg = config.devos;
in {
  imports = [ ./common.nix ];

  options.devos = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether or not to enable DevOS
      '';
    };

    system = {
      locale = mkOption {
        type = types.str;
        default = "en_US.utf8";
        description = ''
          Locale of the system
        '';
      };
    };

    user = mkOption {
      type = types.str;
      description = ''
        User name of the main user of the system
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      bash
      ctop
      curl
      fd
      file
      gitFull
      ncdu
      neofetch
      python3Full
      ripgrep
      wget
    ];

    i18n.defaultLocale = cfg.system.locale;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = cfg.system.locale;
      LC_IDENTIFICATION = cfg.system.locale;
      LC_MEASUREMENT = cfg.system.locale;
      LC_MONETARY = cfg.system.locale;
      LC_NAME = cfg.system.locale;
      LC_NUMERIC = cfg.system.locale;
      LC_PAPER = cfg.system.locale;
      LC_TELEPHONE = cfg.system.locale;
      LC_TIME = cfg.system.locale;
    };

    networking.networkmanager.enable = true;

    services.printing.enable = true;

    services.openssh = {
      enable = true;
      permitRootLogin = "no";
      passwordAuthentication = false;
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "gnome3";
    };

    services.pcscd.enable = true;

    # Fix some weirdness with gnome and pinentry
    services.gnome.gnome-online-accounts.enable = mkForce false;
    services.gnome.gnome-keyring.enable = mkForce false;
    programs.seahorse.enable = mkForce false;

    users.users.${config.devos.user} = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      initialPassword = "Burning722";
    };
  };
}

{
  lib,
  config,
  ...
}:
let
  inherit (config.dusk) system username initialPassword;
  inherit (lib) mkForce mkIf;
in
{
  imports = [
    ./bittorrent.nix
    ./nix-index.nix
    ./boot.nix
    ./desktop.nix
    ./networking.nix
    ./virtualisation.nix
    ./nvidia.nix
  ];

  config = {
    age.secrets = {
      "env.sh.age".file = ../../secrets/env.sh.age;
      "nix.conf.age".file = ../../secrets/nix.conf.age;
      "mullvad.age".file = ../../secrets/mullvad.age;
    };

    catppuccin.enable = true;

    i18n.defaultLocale = system.locale;

    i18n.extraLocaleSettings = {
      LC_ADDRESS = system.locale;
      LC_IDENTIFICATION = system.locale;
      LC_MEASUREMENT = system.locale;
      LC_MONETARY = system.locale;
      LC_NAME = system.locale;
      LC_NUMERIC = system.locale;
      LC_PAPER = system.locale;
      LC_TELEPHONE = system.locale;
      LC_TIME = system.locale;
    };

    time.timeZone = system.timezone;

    services = {
      printing.enable = true;

      openssh = {
        enable = true;

        settings = {
          PermitRootLogin = mkForce "no";
          PasswordAuthentication = mkForce false;
          ChallengeResponseAuthentication = mkForce false;
          GSSAPIAuthentication = mkForce false;
          KerberosAuthentication = mkForce false;
          X11Forwarding = mkForce false;
          PermitUserEnvironment = mkForce false;
          AllowAgentForwarding = mkForce false;
          AllowTcpForwarding = mkForce false;
          PermitTunnel = mkForce false;
        };
      };

      pcscd.enable = true;

      # udev rule to support vial keyboards
      udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
      '';
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    # Make clock compatible with windows (for dual boot)
    time.hardwareClockInLocalTime = true;

    users.users.${username} = mkIf config.dusk.system.nixos.createUser {
      inherit initialPassword;

      isNormalUser = true;
      extraGroups = [ "wheel" ];
    };

    system.stateVersion = "24.11";
  };
}

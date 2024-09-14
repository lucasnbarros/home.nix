{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkForce mkIf optionals;

  cfg = config.dusk.system.nixos.networking;

  nameservers = [
    "127.0.0.1"
    "::1"
    "194.242.2.4" # mullvad ad + tracker + malware
    "194.242.2.3" # mullvad ad + tracker
    "194.242.2.2" # mullvad clear
  ];
in
{
  config = mkIf cfg.enable {
    age.secrets = mkIf cfg.mullvad.enable {
      "mullvad.age".file = ../../secrets/mullvad.age;
    };

    environment.systemPackages = [
      pkgs.dnsutils
    ];

    networking = {
      inherit nameservers;

      dhcpcd.enable = false;
      useDHCP = false;

      firewall = {
        checkReversePath = false;
        trustedInterfaces = optionals cfg.tailscale.enable [ "tailscale0" ];
      };

      iproute2.enable = true;

      networkmanager = {
        enable = true;
        dns = mkForce "none";
        insertNameservers = nameservers;
      };

      resolvconf.useLocalResolver = true;
    };

    services = {
      dnscrypt-proxy2.enable = true;

      i2pd = mkIf cfg.i2p.enable {
        enable = true;
        address = "10.0.0.0";

        proto = {
          http.enable = true;
          httpProxy.enable = true;
          i2cp.enable = true;
          socksProxy.enable = true;
        };
      };

      resolved.enable = false;
      tailscale = {
        inherit (cfg.tailscale) enable;
      };
    };

    system.activationScripts = mkIf cfg.mullvad.enable {
      enable-mullvad = {
        deps = [ ];
        text =
          let
            nm = "${pkgs.networkmanager}/bin/nmcli";
          in
          ''
            if $(${nm} connection | grep mullvad0 &>/dev/null); then
              printf 'skip/true' > /tmp/mullvad
            else
              ${nm} connection import type wireguard file ${config.age.secrets."mullvad.age".path}
              printf 'installed/true' > /tmp/nullvad
            fi
          '';
      };
    };

    users.users.${config.dusk.username}.extraGroups = [ "networkmanager" ];
  };
}
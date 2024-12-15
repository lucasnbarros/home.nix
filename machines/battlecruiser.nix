{ inputs, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-pc-ssd
  ];

  config = {
    dusk.system = {
      hostname = "battlecruiser";

      nixos = {
        desktop = {
          alacritty.font.family = "Berkeley Mono NerdFont Mono";
          gaming.gamescope.enable = true;

          hyprland = {
            enable = true;
            monitors = [
              {
                name = "DP-4";

                resolution = {
                  width = 1440;
                  height = 2560;
                };

                position.special = "auto-left";
                refreshRate = 239.96;
                scale = 1.0;
                transform = 1; # Rotate 90 degrees
                vrr = 1;
                bitDepth = 10;
              }
              {
                name = "HDMI-A-2";
                resolution = {
                  width = 3840;
                  height = 2160;
                };
                position.special = "auto-right";
                refreshRate = 120;
                scale = 1.0;
                vrr = 1;
                bitDepth = 10;
              }
            ];
          };
        };

        networking.defaultNetworkInterface = "eno1";

        server = {
          enable = true;
          chat.enable = false;
          sonarr.enable = false;
        };
      };

      zed = {
        buffer_font_family = "Berkeley Mono NerdFont Mono";
        buffer_font_size = "Berkeley Mono NerdFont Mono";
        ui_font_family = "Berkeley Mono NerdFont Mono";
        ui_font_size = "Berkeley Mono NerdFont Mono";
      };
    };

    boot.initrd.kernelModules = [ "kvm-amd" ];

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-uuid/267a2e89-f17c-4ae8-ba84-709fda2a95aa";
        fsType = "ext4";
      };

      "/boot" = {
        device = "/dev/disk/by-uuid/0B55-0450";
        fsType = "vfat";
      };

      "/media" = {
        device = "/dev/disk/by-uuid/12cdcfc5-77b8-4182-994d-a081c22669dd";
        fsType = "ext4";
      };
    };

    # Enable wacom tablets support
    hardware.opentabletdriver.enable = true;

    networking.firewall = {
      allowedTCPPorts = [
        3000
        8096 # Jellyfin
        48010 # Sunshine
      ];

      allowedUDPPorts = [
        48000 # Sunshine
        48010 # Sunshine
      ];
    };

    programs.steam.gamescopeSession.args = [
      "--steam"
      "--adaptive-sync"

      "-r"
      "120"

      "--prefer-output"
      "HDMI-2"

      "--output-width"
      "1920"

      "--output-height"
      "1080"
    ];

    swapDevices = [ ];

    # Workaround fix for nm-online-service from stalling on Wireguard interface.
    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}

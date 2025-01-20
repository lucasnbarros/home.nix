{ inputs, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-gpu-amd
    common-pc-ssd
  ];

  config = {
    dusk.system = {
      hostname = "terminus";

      monitors = [
        {
          name = "DP-1";

          bitDepth = 8;
          position = {
            x = 0;
            y = 0;
          };
          refreshRate = 74.99;
          resolution = {
            width = 2560;
            height = 1080;
          };
          scale = 1.0;
          transform = {
            rotate = 0;
            flipped = false;
          };
          vrr = false;
        }
      ];

      nixos = {
        nvidia.enable = false;

        desktop = {
          gaming.gamescope.enable = true;
          gnome.enable = true;
          hyprland.enable = true;
        };

        server.enable = false;
      };
    };

    boot.kernelModules = [ "kvm-amd" ];

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/636a0fd5-38c7-4953-aabb-8285e568e42c";
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/72D3-11C2";
      fsType = "vfat";
      options = [
        "fmask=0077"
        "dmask=0077"
      ];
    };

    swapDevices = [ { device = "/dev/disk/by-uuid/bc5301c5-fd5c-4d0c-8b0b-2ef35faf5a2d"; } ];

    # Workaround fix for nm-online-service from stalling on Wireguard interface.
    # https://github.com/NixOS/nixpkgs/issues/180175
    systemd.services.NetworkManager-wait-online.enable = false;
  };
}

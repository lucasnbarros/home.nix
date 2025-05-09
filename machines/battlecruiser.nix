{ inputs, ... }:
{
  imports = with inputs.nixos-hardware.nixosModules; [
    common-cpu-amd
    common-pc-ssd
  ];

  config = {
    dusk = {
      terminal = {
        font-family = "Berkeley Mono NerdFont Mono";
        font-size = 12;
      };

      shell.starship.disabledModules = [
        "cmd_duration"
        "dart"
        "fossil_branch"
        "fossil_metrics"
        "git_branch"
        "git_commit"
        "git_metrics"
        "git_state"
        "git_status"
        "gradle"
        "guix_shell"
        "hg_branch"
        "java"
        "package"
        "package"
        "pijul_channel"
        "vagrant"
      ];

      system = {
        hostname = "battlecruiser";

        monitors = [
          {
            name = "DP-4";

            bitDepth = 10;
            position = {
              x = 0;
              y = 0;
            };
            refreshRate = 239.96;
            resolution = {
              width = 2560;
              height = 1440;
            };
            scale = 1.0;
            transform = {
              rotate = 90;
              flipped = false;
            };
            vrr = true;
          }
          {
            name = "HDMI-A-2";

            bitDepth = 10;
            position = {
              x = 1440;
              y = 2560 - 2160;
            };
            refreshRate = 119.88;
            resolution = {
              width = 3840;
              height = 2160;
            };
            scale = 1.0;
            transform = {
              rotate = 0;
              flipped = false;
            };
            vrr = true;
          }
        ];

        nixos = {
          desktop = {
            gaming.gamescope.enable = true;
            hyprland.enable = true;
          };

          server = {
            enable = true;
            domain = "cfcosta.cloud";
          };
        };

        zed = {
          buffer_font_family = "Berkeley Mono NerdFont Mono";
          buffer_font_size = "Berkeley Mono NerdFont Mono";
          ui_font_family = "Berkeley Mono NerdFont Mono";
          ui_font_size = "Berkeley Mono NerdFont Mono";
        };
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

    programs.steam.gamescopeSession.args = [
      "--steam"
      "--adaptive-sync"
      "--hdr-enabled"

      "-r"
      "120"

      "--output-width"
      "3840"

      "--output-height"
      "2160"
    ];

    swapDevices = [ ];
  };
}

{
  config,
  flavor,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
  inherit (pkgs.stdenv) isLinux;

  mkEnabledOption =
    {
      description ? "Enable unnamed module",
      parent ? null,
    }:
    mkOption {
      inherit description;

      type = types.bool;
      default = parent == null || parent;
    };
in
{
  options.dusk = {
    initialPassword = mkOption {
      type = types.str;
      description = "Initial password for the created user in the system ";
      default = "dusk";
    };

    accounts.github = mkOption {
      type = types.str;
      description = "The user Github Account";
    };

    emails = {
      primary = mkOption {
        type = types.str;
        description = "The primary email used by the user";
      };

      additional = mkOption {
        type = types.listOf types.str;
        description = "Additional email addresses for the user";
        default = [ ];
      };
    };

    name = mkOption {
      type = types.str;
      description = "The full name of the user";
    };

    username = mkOption {
      type = types.str;
      description = "User name of the main user of the system ";
    };

    defaults = {
      browser = mkOption {
        type = types.str;
        description = "Your default browser";
        default = "firefox";
      };

      terminal = mkOption {
        type = types.str;
        description = "Your default terminal emulator";
        default = if config.dusk.system.nixos.desktop.alacritty.enable then "alacritty" else "cosmic-term";
      };
    };

    folders =
      let
        home = if isLinux then "/home/${config.dusk.username}" else "/Users/${config.dusk.username}";
      in
      {
        code = mkOption {
          type = types.str;
          description = "Where you host your working projects";
          default = "${home}/Code";
        };

        downloads = mkOption {
          type = types.str;
          description = "Where you host your Downloads";
          default = "${home}/Downloads";
        };

        home = mkOption {
          type = types.str;
          description = "Your home folder";
          default = home;
        };

        mail = mkOption {
          type = types.str;
          description = "Your root mail folder";
          default = "${home}/Mail";
        };
      };

    system = {
      hostname = mkOption {
        type = types.str;
        description = "The hostname of the system on the network";
        default = "dusk";
      };

      locale = mkOption {
        type = types.str;
        default = "en_US.utf8";
        description = "Locale of the system ";
      };

      timezone = mkOption {
        type = types.str;
        default = "America/Sao_Paulo";
        description = "Timezone to use for the system";
      };

      git = {
        signByDefault = mkOption {
          type = types.bool;
          default = true;
          description = "Whether or not git should sign all commits";
        };

        defaultBranch = mkOption {
          type = types.str;
          default = "main";
          description = "The default branch to use for new git repositories";
        };
      };

      nixos =
        let
          cfg = config.dusk.system.nixos;
        in
        {
          enable = mkOption {
            description = "Whether or not to enable NixOS Modules";
            default = flavor == "nixos";
          };

          createUser = mkEnabledOption {
            description = "Whether or not to create the main user";
            parent = cfg.enable;
          };

          bootloader.enable = mkEnabledOption {
            description = "Whether or not to install a bootloader";
            parent = cfg.enable;
          };

          nvidia.enable = mkEnabledOption {
            description = "Whether or not to enable support for Nvidia Cards";
            parent = cfg.enable;
          };

          desktop = {
            enable = mkEnabledOption {
              description = "Whether or not to enable the Graphical Desktop";
              parent = cfg.enable;
            };

            alacritty = {
              enable = mkEnabledOption {
                description = "Whether or not to enable the Alacritty Terminal";
                parent = cfg.desktop.enable;
              };

              font = {
                family = mkOption {
                  type = types.str;
                  default = "Inconsolata NerdFont Mono";
                };

                size = mkOption {
                  type = types.float;
                  default = 14.0;
                };
              };
            };
          };

          networking = {
            enable = mkEnabledOption {
              description = "Whether or not to enable NetworkManager";
              parent = cfg.enable;
            };

            defaultNetworkInterface = mkOption {
              type = types.str;
              default = "eno1";
              description = "The name of the main network interface for the host";
            };

            i2p.enable = mkEnabledOption {
              description = "Whether or not to enable i2p";
              parent = cfg.networking.enable;
            };

            mullvad.enable = mkEnabledOption {
              description = "Whether or not to enable Mullvad VPN";
              parent = cfg.networking.enable;
            };

            tailscale.enable = mkEnabledOption {
              description = "Whether or not to enable Tailscale VPN";
              parent = cfg.networking.enable;
            };
          };

          virtualisation = {
            enable = mkEnabledOption {
              description = "Whether or not to enable Virtualisation Tooling";
            };

            docker.enable = mkEnabledOption {
              description = "Whether or not to enable Docker";
              parent = cfg.virtualisation.enable;
            };

            libvirt.enable = mkEnabledOption {
              description = "Whether or not to enable LibVirt";
              parent = cfg.virtualisation.enable;
            };

            podman.enable = mkEnabledOption {
              description = "Whether or not to enable Podman";
              parent = cfg.virtualisation.enable;
            };

            waydroid.enable = mkEnabledOption {
              description = "Whether or not to enable Waydroid (run android apps on Linux)";
              parent = cfg.virtualisation.enable;
            };
          };

          server = {
            enable = lib.mkEnableOption "Whether or not to install the server infrastructure";

            domain = mkOption {
              type = types.str;
              default = "${config.dusk.system.hostname}.local";
              description = "The root domain for all services in the system";
            };

            cockpit.enable = mkEnabledOption {
              description = "Whether or not to install the Cockpit Server Dashboard";
              parent = cfg.server.enable;
            };

            gitea.enable = mkEnabledOption {
              description = "Whether or not to install the Gitea Git Server";
              parent = cfg.server.enable;
            };

            transmission.enable = mkEnabledOption {
              description = "Whether or not to install the transmission bittorrent server";
              parent = cfg.server.enable;
            };
          };
        };
    };

    tmux.showBattery = lib.mkEnableOption "tmux show battery level";
  };
}
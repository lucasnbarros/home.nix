{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.dusk.system;

  inherit (import ../lib/monitors.nix) formatMonitor getPrimaryMonitor;
in
{
  options.dusk.system.monitors =
    with lib;
    mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            name = mkOption {
              type = types.str;
              description = "Monitor name/identifier";
            };
            primary = mkOption {
              type = types.bool;
              default = false;
              description = "Whether this is the primary display";
            };
            resolution = mkOption {
              type = types.submodule {
                options = {
                  width = mkOption {
                    type = types.int;
                    description = "Monitor width in pixels";
                  };
                  height = mkOption {
                    type = types.int;
                    description = "Monitor height in pixels";
                  };
                };
              };
              description = "Monitor resolution configuration";
            };
            position = mkOption {
              type = types.submodule {
                options = {
                  x = mkOption {
                    type = types.int;
                    description = "Monitor X position";
                  };
                  y = mkOption {
                    type = types.int;
                    description = "Monitor Y position";
                  };
                };
              };
              description = "Monitor position configuration";
            };
            refreshRate = mkOption {
              type = types.either types.int types.float;
              default = 60;
              description = "Monitor refresh rate in Hz";
            };
            scale = mkOption {
              type = types.either types.float (types.enum [ "auto" ]);
              default = 1.0;
              description = "Monitor scale factor (can be 'auto' or a float)";
            };
            mirror = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Name of the monitor to mirror";
            };
            bitDepth = mkOption {
              type = types.nullOr (
                types.enum [
                  8
                  10
                ]
              );
              default = null;
              description = "Color bit depth (8 or 10)";
            };
            vrr = mkOption {
              type = types.oneOf [
                types.bool
                (types.enum [ "fullscreen-only" ])
              ];
              default = false;
              description = ''
                Variable refresh rate (false: off, true: on, "fullscreen-only": only when running a full-screen application)";
              '';
            };
            transform = mkOption {
              type = types.submodule {
                options = {
                  rotate = mkOption {
                    type = types.enum [
                      0
                      90
                      180
                      270
                    ];
                    default = 0;
                    description = "Rotation in degrees (0, 90, 180, or 270)";
                  };
                  flipped = mkOption {
                    type = types.bool;
                    default = false;
                    description = "Whether the output is flipped";
                  };
                };
              };
              default = {
                rotate = 0;
                flipped = false;
              };
              description = "Transform configuration for rotation and flipping";
            };
          };
        }
      );
      default = [ ];
      description = "Monitor configurations";
    };

  config = {
    environment.etc."gnome-settings-daemon/monitors.xml" =
      mkIf (cfg.nixos.desktop.gnome.enable && (cfg.monitors != [ ]))
        {
          text = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <monitors version="2">
              <configuration>
                ${lib.concatMapStrings (monitor: ''
                  <logicalmonitor>
                    <x>${toString monitor.position.x}</x>
                    <y>${toString monitor.position.y}</y>
                    <scale>${if monitor.scale == "auto" then "1" else toString monitor.scale}</scale>
                    <primary>${if monitor.name == getPrimaryMonitor cfg.monitors then "yes" else "no"}</primary>
                    <monitor>
                      <monitorspec>
                        <connector>${monitor.name}</connector>
                        <vendor>unknown</vendor>
                        <product>unknown</product>
                        <serial>unknown</serial>
                      </monitorspec>
                      <mode>
                        <width>${toString monitor.resolution.width}</width>
                        <height>${toString monitor.resolution.height}</height>
                        <rate>${toString monitor.refreshRate}</rate>
                      </mode>
                      <transform>
                        <rotation>${
                          if monitor.transform.rotate == 0 then
                            "normal"
                          else if monitor.transform.rotate == 90 then
                            "right"
                          else if monitor.transform.rotate == 180 then
                            "upside_down"
                          else if monitor.transform.rotate == 270 then
                            "left"
                          else
                            throw "Invalid rotation value"
                        }</rotation>
                        <flipped>${if monitor.transform.flipped then "yes" else "no"}</flipped>
                      </transform>
                    </monitor>
                  </logicalmonitor>
                '') cfg.monitors}
              </configuration>
            </monitors>
          '';
        };

    home-manager.users.${config.dusk.username} = {
      dconf.settings = mkIf (cfg.nixos.desktop.gnome.enable && (cfg.monitors != [ ])) {
        "org/gnome/mutter" = {
          experimental-features = [ "scale-monitor-framebuffer" ];
        };

        "org/gnome/desktop/interface" = {
          scaling-factor = 1;
        };

        "org/gnome/mutter/displays" = {
          monitors-config-format = "json";
          monitors-config = builtins.toJSON {
            version = 2;
            monitors = map (formatMonitor.gnome cfg.monitors) cfg.monitors;
          };
        };
      };

      wayland.windowManager.hyprland = mkIf (cfg.nixos.desktop.hyprland.enable && (cfg.monitors != [ ])) {
        settings.monitor = map formatMonitor.hyprland cfg.monitors;
      };
    };
  };
}

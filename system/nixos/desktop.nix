{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dusk.system.nixos.desktop;

  inherit (config.dusk) username;
  inherit (config.dusk.folders) home;
  inherit (lib) mkIf optionals;
in
{
  config = mkIf cfg.enable {
    environment = {
      sessionVariables = {
        BROWSER = config.dusk.defaults.browser;
        TERMINAL = config.dusk.defaults.terminal;
      };

      systemPackages =
        with pkgs;
        [
          anytype
          astroid
          bitwarden
          brave
          discord
          easyeffects
          element-desktop
          firefox
          fractal
          helvum
          mangohud
          mullvad-browser
          obs-studio
          streamlink-twitch-gui-bin
          tdesktop
          todoist-electron
          tor-browser
          wl-clipboard
          zed-editor

          # Fonts
          cantarell-fonts
          dejavu_fonts
          source-code-pro
          source-sans
        ]
        ++ optionals cfg.alacritty.enable [ alacritty ]
        ++ optionals config.dusk.system.nixos.virtualisation.libvirt.enable [ virt-manager ];
    };

    hardware = {
      graphics.enable = true;
      pulseaudio.enable = false;
    };

    home-manager.users.${config.dusk.username}.xdg.configFile = {
      "cosmic/com.system76.CosmicComp/v1/autotile".text = "true";
      "cosmic/com.system76.CosmicComp/v1/autotile_behavior".text = "true";
      "cosmic/com.system76.CosmicComp/v1/cursor_follows_focus".text = "true";
      "cosmic/com.system76.CosmicComp/v1/focus_follows_cursor".text = "true";
      "cosmic/com.system76.CosmicTheme.Dark.Builder/v1/gaps".text = "(8, 24)";
      "cosmic/com.system76.CosmicTheme.Dark.Builder/v1/palette".source = "${inputs.catppuccin-cosmic}/cosmic-settings/Catppuccin-Mocha-Blue.ron";
      "cosmic/com.system76.CosmicTheme.Dark/v1/gaps".text = "(8, 24)";
      "cosmic/com.system76.CosmicTheme.Dark/v1/palette".source = "${inputs.catppuccin-cosmic}/cosmic-settings/Catppuccin-Mocha-Blue.ron";
      "cosmic/com.system76.CosmicTk/v1/apply_theme_global".text = "true";
      "cosmic/com.system76.CosmicSettings.Shortcuts/v1/custom".source = ./cosmic/shortcuts.ron;
    };

    nix.settings = {
      substituters = [ "https://cosmic.cachix.org/" ];

      trusted-public-keys = [
        "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
      ];
    };

    programs = {
      gnupg.agent.pinentryPackage = pkgs.pinentry-all;
      steam.enable = true;
    };

    security.rtkit.enable = true;

    services = {
      avahi =
        let
          net = config.dusk.system.nixos.networking;
        in
        {
          enable = true;

          allowInterfaces = [
            net.defaultNetworkInterface
          ] ++ optionals net.tailscale.enable [ "tailscale0" ];

          publish = {
            enable = true;

            domain = true;
            userServices = true;
          };

          nssmdns4 = true;
          nssmdns6 = true;
        };

      desktopManager.cosmic.enable = true;
      flatpak.enable = true;
      libinput.enable = true;
      packagekit.enable = true;

      pipewire = {
        enable = true;

        pulse.enable = true;
        jack.enable = true;
      };

      syncthing = {
        enable = true;

        user = username;
        dataDir = "${home}/Sync";
      };

      xserver = {
        enable = true;

        displayManager.gdm = {
          enable = true;
          autoSuspend = false;
          wayland = true;
        };
      };
    };
  };
}
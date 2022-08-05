{ lib, pkgs, config, ... }: {
  imports = [
    ./containers.nix
    ./core.nix
    ./gaming.nix
    ./gnome.nix
    ./icognito.nix
    ./sound.nix
    ./tailscale.nix
    ./virtualisation.nix
  ];
}

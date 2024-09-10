{ pkgs, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ./options.nix
    ./themes
  ];

  environment.etc."nix/inputs/nixpkgs".source = "${pkgs.dusk.inputs.nixpkgs}";

  nix = {
    useDaemon = true;

    gc.automatic = true;

    settings = {
      accept-flake-config = true;
      allow-import-from-derivation = true;
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      extra-substituters = [
        "https://cache.iog.io"
        "https://hydra-node.cachix.org"
        "https://cardano-scaling.cachix.org"
      ];

      extra-trusted-public-keys = [
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
        "hydra-node.cachix.org-1:vK4mOEQDQKl9FTbq76NjOuNaRD4pZLxi1yri31HHmIw="
        "cardano-scaling.cachix.org-1:RKvHKhGs/b6CBDqzKbDk0Rv6sod2kPSXLwPzcUQg9lY="
      ];

      system-features = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ="
      ];

      substituters = [
        "https://cache.nixos.org/"
        "https://cache.iog.io/"
      ];
    };

    # Configure nix to use the flake's nixpkgs
    registry.nixpkgs.flake = pkgs.dusk.inputs.nixpkgs;
    nixPath = mkForce [ "/etc/nix/inputs" ];
  };
}

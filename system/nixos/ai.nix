{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  config = mkIf config.dusk.system.nixos.ai.enable {
    services.ollama = {
      enable = true;
      acceleration = null;
    };
  };
}
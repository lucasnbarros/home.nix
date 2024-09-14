{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf;

  hostConfig = (import ./lib.nix).exposeHost {
    name = "gitea";
    domain = "gitea.${cfg.domain}";
    port = config.services.gitea.settings.server.HTTP_PORT;
  };

  cfg = config.dusk.system.nixos.server;
in
{
  config =
    mkIf cfg.gitea.enable {
      services.gitea = {
        enable = true;

        settings.server = {
          HTTP_ADDRESS = "0.0.0.0";
          HTTP_PORT = 10002;

          ROOT_URL = "https://gitea.${cfg.domain}";
        };
      };
    }
    // hostConfig;
}
{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.dusk.home.alacritty;

  font = style: {
    inherit style;
    inherit (cfg.font) family;
  };
in
{
  options = {
    dusk.home.alacritty = {
      enable = mkEnableOption "alacritty";

      font = {
        family = mkOption {
          type = types.str;
          default = "Inconsolata";
        };

        size = mkOption {
          type = types.float;
          default = 14.0;
        };
      };
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";

        font = {
          normal = font "Medium";
          bold = font "Bold";
          italic = font "Medium Italic";
          bold_italic = font "Bold Italic";
          inherit (cfg.font) size;
        };
      };
    };
  };
}

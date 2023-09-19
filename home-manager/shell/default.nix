{ config, lib, pkgs, ... }:
with lib;
let cfg = config.dusk.home;
in {
  options = {
    dusk.home.shell = {
      environmentFile = mkOption {
        type = types.str;
        default = "${cfg.folders.home}/dusk-env.sh";
        description = ''
          A bash file that is loaded by the shell on each run.
          This is used to set secrets or credentials that we don't want on the repo.
        '';
      };
    };
  };

  config = rec {
    home.packages = with pkgs; [ bashInteractive complete-alias ];

    programs.bash = {
      enable = true;
      enableCompletion = true;

      shellAliases = {
        ack = "rg";
        bc = "eva";
        cat = "bat --decorations=never";
        g = "git status --short";
        gc = "git commit";
        gca = "git commit -a";
        gco = "git checkout";
        gcp = "git cherry-pick";
        gd = "git diff";
        gf = "git fetch -a";
        gl = "git log --graph";
        gp = "git push";
        gs = "git stash";
        gsp = "git stash pop";
        jd = "jj diff";
        jl = "jj log";
        ls = "lsd -l";
        ll = "lsd -l -A";
        vi = "nvim";
        vim = "nvim";
      };

      sessionVariables = {
        COLORTERM = "truecolor";
        EDITOR = "nvim";
        CDPATH = ".:${cfg.folders.code}";
        MANPAGER = "${pkgs.less}/bin/less -s -M +Gg";
      };

      historySize = 1000000;

      # Ignore common transaction commands and the aliases we've set.
      historyIgnore = [ "exit" "pwd" "reset" "fg" "jobs" ]
        ++ (mapAttrsToList (key: _: key) config.programs.bash.shellAliases);

      shellOptions = [
        # Default options from home-manager
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"

        # Custom Options
        "cdspell" # Correct transpositions and other minor details from 'cd DIR' command.
        "dotglob" # Include hidden files in glob (*).
        "extglob" # Extra-special pattern matching in the shell.
        "cmdhist" # Flatten multiple-line commands into the same history entry.
        "no_empty_cmd_completion" # Don't complete when I haven't typed anything.
        "shift_verbose" # Let me know if I shift stupidly.
      ];

      initExtra = ''
        . ${pkgs.complete-alias}/bin/complete_alias

        ${builtins.concatStringsSep "\n"
        (builtins.map (alias: "complete -F _complete_alias ${alias}")
          (builtins.attrNames config.programs.bash.shellAliases))}
      '';

      bashrcExtra = ''
        ${if pkgs.stdenv.isDarwin then
          (builtins.readFile ./shell/macos.sh)
        else
          ""}

        # Man-pages coloring with Dracula theme
        export LESS_TERMCAP_mb=$'\e[1;31m'      # begin bold
        export LESS_TERMCAP_md=$'\e[1;34m'      # begin blink
        export LESS_TERMCAP_so=$'\e[01;45;37m'  # begin reverse video
        export LESS_TERMCAP_us=$'\e[01;36m'     # begin underline
        export LESS_TERMCAP_me=$'\e[0m'         # reset bold/blink
        export LESS_TERMCAP_se=$'\e[0m'         # reset reverse video
        export LESS_TERMCAP_ue=$'\e[0m'         # reset underline

        [ -f "${cfg.shell.environmentFile}" ] && source "${cfg.shell.environmentFile}"
      '';
    };

    programs.readline = {
      enable = true;

      extraConfig = ''
        # If there's more than one completion for an input, list all options immediately 
        # instead of waiting for a second input.
        set show-all-if-ambiguous on
      '';
    };

    # Make ctrl-r much more powerful
    # https://github.com/ellie/atuin
    programs.atuin = {
      enable = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        auto_sync = false;
        update_check = false;
        style = "compact";
        show_help = false;

        history_filter = [ "^ls" "^cd" "^cat" "^fg" "^jobs" ]
          ++ (builtins.map (alias: ''"^${alias}"'')
            (builtins.attrNames config.programs.bash.shellAliases));
      };
    };

    programs.lsd = {
      enable = true;

      settings = {
        blocks = [ "permission" "user" "size" "git" "name" ];
        icons.theme = "fancy";
        ignore-globs = [ ".direnv" ".git" ".hg" ".jj" ];
        permission = "rwx";
      };
    };

    home.file.".config/lsd/colors.yaml".text =
      builtins.readFile ./lsd/colors.yaml;

    programs.zoxide.enable = true;
  };
}
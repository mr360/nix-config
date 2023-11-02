{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.task;

  taskSpec = types.submodule {
    options = {
      script = mkOption {
        type = types.lines;
        description = "The script to execute.";
      };
      onCalendar = mkOption {
        type = types.str;
        description = "The systemd time specification.";
      };
      user = mkOption {
        type = types.str;
        description = "The user to run the service as.";
        default = "root";
      };
      path = mkOption {
        type = types.listOf types.package;
        default = [ ];
        description = "List of pkgs in the path for the service script.";
      };
    };
  };

  mkService = name:
    { script, path, user, ... }: {
      serviceConfig.Type = "oneshot";
      serviceConfig.User = user;
      script = script;
      path = path;
    };

  mkTimer = name:
    { onCalendar, ... }: {
      wantedBy = [ "timers.target" ];
      partOf = [ "${name}.service" ];
      timerConfig.OnCalendar = onCalendar;
    };

in {
  options.task = mkOption {
    type = types.attrsOf taskSpec;
    description = { };
    default = { };
  };

  config.systemd.services = let
    units = mapAttrs' (name: info: {
      name = "${name}";
      value = (mkService name info);
    }) cfg;
  in units;

  config.systemd.timers = let
    timers = mapAttrs' (name: info: {
      name = "${name}";
      value = (mkTimer name info);
    }) cfg;
  in timers;
}
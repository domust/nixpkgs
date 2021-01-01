{ config, lib, pkgs, ... }:

let
  cfg = config.services.nordvpn;
in

with lib;

{
  options.services.nordvpn.enable = mkOption {
    type = types.bool;
    default = false;
    description = "If enabled, starts NordVPN daemon.";
  };

  config = mkIf cfg.enable {
    boot.kernelModules = [ "tun" ];
    networking.iproute2.enable = true;
    environment.systemPackages = [ pkgs.nordvpn ];
    services.dbus.packages = [ pkgs.nordvpn ];
    systemd.packages = [ pkgs.nordvpn ];
  };
}

{...}: {
  flake.nixosModules.variousServices = {...}: {
    services = {
      pipewire = {
        enable = true;
        pulse.enable = true;
      };
      timesyncd.enable = true;
      openssh = {
        enable = true;
        settings.PermitRootLogin = "no";
      };
      xserver = {
        xkb = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle";
        };
      };
    };
    networking = {
      firewall = {
        enable = true;
        extraCommands = ''
          # Allow ALL traffic from local network
          iptables -I INPUT 1 -s 192.168.0.0/16 -j ACCEPT
          ip6tables -I INPUT 1 -s fd00::/8 -j ACCEPT
          ip6tables -I INPUT 1 -s fe80::/10 -j ACCEPT
        '';
      };
    };
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
    services.usbmuxd.enable = true;
  };
}

{inputs, ...}: {
  flake.nixosModules.boot = {pkgs, ...}: {
    imports = [
      # inputs.self.nixosModules."boot@secureBoot"
    ];
    boot = {
      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot/efi";
        };
        systemd-boot = {
          enable = true;
          editor = false;
          consoleMode = "max";
        };
        timeout = 0;
      };

      initrd = {
        systemd.enable = true;
        verbose = false;
      };

      plymouth.enable = true;

      consoleLogLevel = 3;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"
      ];
    };
  };

  flake.nixosModules."boot@secureBoot" = {pkgs, ...}: {
    imports = [
      inputs.lanzaboote.nixosModules.lanzaboote
    ];
    environment.systemPackages = [
      pkgs.sbctl
    ];

    boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
    };
  };
}

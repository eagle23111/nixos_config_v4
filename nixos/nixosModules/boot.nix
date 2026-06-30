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

      #plymouth = {
      #  enable = true;
      #  theme = "spin";
      #  themePackages = with pkgs; [
      #    (adi1090x-plymouth-themes.override {
      #      selected_themes = ["spin"];
      #    })
      #  ];
      #};
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
      # For debugging and troubleshooting Secure Boot.
      pkgs.sbctl
    ];

    # Lanzaboote currently replaces the systemd-boot module.
    # This setting is usually set to true in configuration.nix
    # generated at installation time. So we force it to false
    # for now.
    boot.loader.systemd-boot.enable = pkgs.lib.mkForce false;

    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      autoGenerateKeys.enable = true;
      autoEnrollKeys.enable = true;
    };
  };
}

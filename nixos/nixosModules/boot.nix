{inputs, ...}: {
  flake.nixosModules.boot = {pkgs, ...}: {
boot = {
  loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    systemd-boot = {
      enable = true;
      editor = false;
      #timeout = 1;                # equivalent to the previous boot.timeout
    };
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

  flake.nixosModules."boot@secureBoot" = {pkgs,...}:{

  };
}

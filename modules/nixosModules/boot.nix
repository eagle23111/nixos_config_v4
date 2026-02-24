{pkgs, ...}: {
  flake.nixosModules.boot = {pkgs, ...}: {
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.efi.efiSysMountPoint = "/boot/efi";
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
    };
    boot.initrd.systemd.enable = true;

    boot = {
      plymouth = {
        enable = true;
        theme = "spin";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = ["spin"];
          })
        ];
      };

      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"
      ];
      loader.timeout = 0;
    };
  };
}

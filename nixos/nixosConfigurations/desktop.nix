{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.desktop =
    inputs.nixpkgs.lib.nixosSystem
    {
      modules = [
        self.nixosModules.caches
        self.nixosModules.bypassCen
        self.nixosModules.consoleUtils
        self.nixosModules.gaming
        self.nixosModules.nixLD
        self.nixosModules.nvidia
        self.nixosModules.qemu
        self.nixosModules.snapper

        self.nixosModules.boot
        self.nixosModules.nix
        self.nixosModules.variousServices

        self.nixosModules.gnome

        self.nixosModules.desktopModule
        self.nixosModules.desktopHardware
      ];
    };

  flake.nixosModules.desktopModule = {
    pkgs,
    inputs,
    lib,
    ...
  }: {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    home-manager.users.mortal = self.homeModules."mortal@desktop";
    home-manager.backupFileExtension = "hm-backup";

    networking.hostName = "nixos";

    time.timeZone = "Europe/Moscow";

    users = {
      users.mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
      };
      defaultUserShell = pkgs.zsh;
    };

    system.stateVersion = "26.05";
  };

  flake.nixosModules.desktopHardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot = {
      initrd = {
        availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
        kernelModules = [];
        luks.devices = {
          c1 = {
            device = "/dev/disk/by-uuid/acfd84bf-57d3-4861-bf0e-bdb439914e90";
            allowDiscards = true;
          };
          c2 = {
            device = "/dev/disk/by-uuid/2637479b-f5c9-4292-bd73-a6d008add595";
            allowDiscards = true;
          };
          c3 = {
            device = "/dev/disk/by-uuid/304973dd-9fb5-45fd-824a-c2a948af0ecf";
            allowDiscards = true;
          };
          swap = {
            device = "/dev/disk/by-uuid/195a764d-3bc7-4cc5-8584-e3d2d6a1dece";
            allowDiscards = true;
          };
        };
      };
      kernelModules = ["kvm-amd ntsync"];
      extraModulePackages = [];
    };

    fileSystems = {
      "/" = {
        device = "/dev/mapper/c3";
        fsType = "btrfs";
        options = ["subvol=nixos"];
      };
      "/home" = {
        device = "/dev/mapper/c3";
        fsType = "btrfs";
        options = ["subvol=home"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/f6286dc8-eea4-4662-b92a-b2ea0992d6ca";
        fsType = "ext4";
      };
      "/boot/efi" = {
        device = "/dev/disk/by-uuid/363C-6B10";
        fsType = "vfat";
        options = ["fmask=0022" "dmask=0022"];
      };
    };

    swapDevices = [
      {device = "/dev/mapper/swap";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}

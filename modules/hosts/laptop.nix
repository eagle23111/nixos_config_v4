{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.laptop =
    inputs.nixpkgs.lib.nixosSystem
    {
      modules = [
        self.nixosModules.caches
        self.nixosModules.bypassCen
        self.nixosModules.consoleUtils
        self.nixosModules.gaming
        self.nixosModules.nixLD
        self.nixosModules.qemu
        self.nixosModules.snapper
        self.nixosModules.boot

        self.nixosModules.gnome
        #self.nixosModules.niri

        self.nixosModules.laptopModule
        self.nixosModules.laptopHardware
      ];
    };

  flake.nixosModules.laptopModule = {
    pkgs,
    inputs,
    lib,
    ...
  }: {
    services.usbmuxd.enable = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

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
      hostName = "nixos";
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

    time.timeZone = "Europe/Moscow";

    users = {
      users.mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
      };
      defaultUserShell = pkgs.zsh;
    };

    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;

    system.stateVersion = "26.05";
  };

  flake.nixosModules.laptopHardware = {
    config,
    lib,
    pkgs,
    modulesPath,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = ["subvol=@" "compress=zstd"];
    };

    boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/3b92a947-0b7c-4908-a76e-a6ba62a6a625";
    boot.initrd.luks.devices."cryptswap".device = "/dev/disk/by-partlabel/swap";

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/310b3bc6-c04f-40e6-bf96-6e18f1fdca25";
      fsType = "ext4";
    };

    fileSystems."/home" = {
      device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = ["subvol=@home" "compress=zstd"];
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/488E-6B62";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [
      {device = "/dev/mapper/cryptswap";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.npu.enable = true;
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}

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
        self.nixosModules.gaming
        self.nixosModules.nixLD
        self.nixosModules.qemu
        self.nixosModules.snapper

        self.nixosModules.boot
        self.nixosModules.nix
        self.nixosModules.variousServices
        self.nixosModules.consoleUtils

        self.nixosModules.stylix
        self.nixosModules.gnome

        self.nixosModules.laptopModule
        self.nixosModules.laptopHardware

        inputs.home-manager.nixosModules.home-manager
      ];
    };

  flake.nixosModules.laptopModule = {
    pkgs,
    inputs,
    lib,
    ...
  }: {
    boot.kernelPackages = pkgs.linuxPackages_latest;

    home-manager.users.mortal = self.homeModules."mortal@laptop";
    home-manager.backupFileExtension = "hm-backup";

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # VA-API video acceleration (iHD)
        vpl-gpu-rt # Intel Quick Sync Video (QSV)
        intel-compute-runtime # OpenCL and Level Zero for compute tasks
      ];
    };

    # Set environment variable to use the modern Intel driver backend
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
    };

    hardware.enableRedistributableFirmware = true;
    boot.initrd.kernelModules = ["xe"];
    boot.kernelParams = ["i915.enable_psr=0"];

    services.power-profiles-daemon.enable = true;
    services.thermald.enable = true;

    #services.fprintd.enable = true;
    #services.fprintd.tod.enable = true;

    networking.hostName = "nixoslaptop";
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
      # options = ["umask=0077"];
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

{
  inputs,
  self,
  ...
}: {
  flake.nixosConfigurations.macbook =
    inputs.nixpkgs.lib.nixosSystem
    {
      system = "aarch64-linux";
      modules = [
        inputs.apple-silicon.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
        inputs.stylix.nixosModules.stylix

        self.nixosModules.macbookModule
        self.nixosModules.macbookHardware
        self.nixosModules.caches
        self.nixosModules.consoleUtils
        self.nixosModules.gnome

        self.nixosModules.nix
        self.nixosModules.variousServices

        self.nixosModules.bypassCen
      ];
    };

  flake.nixosModules.macbookModule = {
    pkgs,
    inputs,
    lib,
    ...
  }: {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = false;
        timeout = 3;
      };
      initrd = {
        systemd.enable = true;
        verbose = false;
      };
      plymouth = {
        enable = true;
        #  theme = "spin";
        #  themePackages = with pkgs; [
        #    (adi1090x-plymouth-themes.override {
        #      selected_themes = ["spin"];
        #    })
        #  ];
      };
      consoleLogLevel = 3;
      kernelParams = [
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"

        "zswap.enabled=1" # enables zswap
        "zswap.compressor=lz4" # compression algorithm
        "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
        "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
      ];
    };

    networking = {
      hostName = "macbook-nixos";
      networkmanager.enable = true;
      wireless = {
        #enable = lib.mkForce false;
        iwd = {
          #enable = true;
          settings.General.EnableNetworkConfiguration = true;
        };
      };
    };

    services.upower.enable = true;
    services.tuned.enable = true;
    time.timeZone = "Europe/Moscow";

    services = {
    };
    libinput = {
      enable = true;
      touchpad = {
        naturalScrolling = true;
        tapping = false;
        clickMethod = "clickfinger";
        disableWhileTyping = true;
        accelProfile = "adaptive";
        #scrollFactor = 0.5;
      };
    };

    hardware = {
      asahi = {
        enable = true;
        setupAsahiSound = true;
        peripheralFirmwareDirectory = "${inputs.self}/assets/macbook-m1-firmware";
      };
      bluetooth.enable = true;
    };

    home-manager.users.mortal = self.homeModules."mortal@macbook";
    home-manager.backupFileExtension = "hm-backup";

    users = {
      users.mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
      };
      defaultUserShell = pkgs.zsh;
    };

    system.stateVersion = "26.05";
  };

  flake.nixosModules.macbookHardware = {
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
        availableKernelModules = ["usb_storage"];
        kernelModules = [];
        luks.devices = {
          c1.device = "/dev/disk/by-uuid/024adab0-5dac-4777-94aa-3b784f5a1a1c";
          swap.device = "/dev/disk/by-uuid/7f4e4878-9d30-4884-98c0-ecff0285f0dd";
        };
      };
      kernelModules = [];
      extraModulePackages = [];
    };

    fileSystems = {
      "/" = {
        device = "/dev/mapper/c1";
        fsType = "btrfs";
        options = ["subvol=@,compress=zstd"];
      };
      "/home" = {
        device = "/dev/mapper/c1";
        fsType = "btrfs";
        options = ["subvol=@home,compress=zstd"];
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/2390-07EB";
        fsType = "vfat";
        options = ["fmask=0022" "dmask=0022"];
      };
    };

    swapDevices = [
      {device = "/dev/mapper/swap";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}

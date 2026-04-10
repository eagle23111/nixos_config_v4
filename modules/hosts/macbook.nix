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
        self.nixosModules.macbookModule
        self.nixosModules.macbookHardware
        self.nixosModules.caches
        self.nixosModules.consoleUtils
        self.nixosModules.niri

        self.nixosModules.bypassCen
      ];
    };

  flake.nixosModules.macbookModule = {
    pkgs,
    inputs,
    lib,
    ...
  }: {
    hardware.asahi.peripheralFirmwareDirectory = ../../assets/macbook-m1-firmware;
    nix.package = pkgs.lix;
    nixpkgs.config.allowUnfree = true;

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = ["root" "@wheel"];
      };
      channel.enable = false;
    };

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
        theme = "spin";
        themePackages = with pkgs; [
          (adi1090x-plymouth-themes.override {
            selected_themes = ["spin"];
          })
        ];
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

    i18n = {
      defaultLocale = "ru_RU.UTF-8";
      extraLocales = ["ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];
    };

    console = {
      useXkbConfig = true;
      earlySetup = true;
      font = "cyr-sun16";
      packages = [pkgs.powerline-fonts];
    };

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [nerd-fonts.terminess-ttf pkgs.terminus_font];
    };

    services = {
      xserver = {
        xkb = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle";
        };
      };
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
          clickMethod = "clickfinger";
          disableWhileTyping = true;
          accelProfile = "adaptive";
          #scrollFactor = 0.5;
        };
      };
      openssh = {
        enable = true;
        settings.PermitRootLogin = "no";
      };
    };

    hardware.asahi = {
      enable = true;
      setupAsahiSound = true;
    };

    users = {
      users.mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
      };
      defaultUserShell = pkgs.zsh;
    };

    programs = {
      zsh = {
        enable = true;
        enableCompletion = true;
        syntaxHighlighting.enable = true;
      };
      firefox.enable = true;
      mtr.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    environment.systemPackages = with pkgs; [
      wget
      git
    ];

    system.stateVersion = "25.11";
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

{
  inputs,
  self,
  pkgs,
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

    nixpkgs.config.allowUnfree = true;
    nix = {
      settings.experimental-features = "nix-command flakes";
      settings.trusted-users = ["root" "@wheel"];

      channel.enable = false;
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = false;
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

        "zswap.enabled=1" # enables zswap
        "zswap.compressor=lz4" # compression algorithm
        "zswap.max_pool_percent=20" # maximum percentage of RAM that zswap is allowed to use
        "zswap.shrinker_enabled=1" # whether to shrink the pool proactively on high memory pressure
      ];
      loader.timeout = 3;
    };

    networking.hostName = "macbook-nixos";

    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Moscow";

    i18n.defaultLocale = "ru_RU.UTF-8";
    i18n.extraLocales = ["ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];
    console = {
      useXkbConfig = true;
      earlySetup = true;
      font = "cyr-sun16";
      packages = [pkgs.powerline-fonts];
    };
    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [nerd-fonts.terminess-ttf pkgs.terminus_font];

    services.xserver.xkb.layout = "us,ru";
    services.xserver.xkb.options = "grp:alt_shift_toggle";

    # services.pulseaudio.enable = true;

    hardware.asahi = {
      enable = true;
      setupAsahiSound = true;
    };
    #services.pipewire = {
    #  enable = true;
    #  alsa.enable = true;
    #  pulse.enable = true;
    #};

    # options.hardware.asahi.enable = true;

    networking.wireless.iwd = {
      enable = true;
      settings.General.EnableNetworkConfiguration = true;
    };

    services.libinput = {
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

    users.users = {
      mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
      };
    };
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;
    programs.zsh.enableCompletion = true;
    programs.zsh.syntaxHighlighting.enable = true;

    programs.firefox.enable = true;
    networking.firewall = {
      enable = true;
      extraCommands = ''
        # Allow ALL traffic from local network
        iptables -I INPUT 1 -s 192.168.0.0/16 -j ACCEPT
        ip6tables -I INPUT 1 -s fd00::/8 -j ACCEPT
        ip6tables -I INPUT 1 -s fe80::/10 -j ACCEPT
      '';
    };
    environment.systemPackages = with pkgs; [
      wget
      git
    ];

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };


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

    boot.initrd.availableKernelModules = ["usb_storage"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/mapper/c1";
      fsType = "btrfs";
      options = ["subvol=@,compress=zstd"];
    };

    boot.initrd.luks.devices."c1".device = "/dev/disk/by-uuid/024adab0-5dac-4777-94aa-3b784f5a1a1c";
    boot.initrd.luks.devices."swap".device = "/dev/disk/by-uuid/7f4e4878-9d30-4884-98c0-ecff0285f0dd";

    fileSystems."/home" = {
      device = "/dev/mapper/c1";
      fsType = "btrfs";
      options = ["subvol=@home,compress=zstd"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/2390-07EB";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [
      {device = "/dev/mapper/swap";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}

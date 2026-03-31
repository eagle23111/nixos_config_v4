{
  inputs,
  self,
  pkgs,
  ...
}: {
  flake.nixosConfigurations.macbook =
    inputs.nixpkgs.lib.nixosSystem
    {
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

    networking.hostName = "macbook-nixos"; # Define your hostname.

    # Configure network connections interactively with nmcli or nmtui.
    networking.networkmanager.enable = true;

    # Set your time zone.
    time.timeZone = "Europe/Moscow";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
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

    #hardware.apple.touchpad = {
    # 	enable = true;
    #	package = pkgs.tiny-dfr;
    # };

    # Enable touchpad support (enabled default in most desktopManager).

    # services.libinput.enable = true;

    #services.xserver.enable = true;
    #services.xserver.desktopManager.xfce.enable = true;

    # Define a user account. Don't forget to set a password with ‘passwd’.
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
    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    environment.systemPackages = with pkgs; [
      vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
      wget
      git
    ];

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };

    programs.nh = {
      enable = true;
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
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

    swapDevices = [];

    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}

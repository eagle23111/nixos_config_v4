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
        self.nixosModules.niri

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
    nixpkgs.config.allowUnfree = true;

    boot.extraModprobeConfig = ''
      options hid_apple fnmode=0
    '';

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

    nix = {
      settings.experimental-features = "nix-command flakes";
      settings.trusted-users = ["root" "@wheel"];

      channel.enable = false;
    };

    #boot.kernelPackages = pkgs.linuxPackages_latest;

    fonts.enableDefaultPackages = true;
    fonts.packages = with pkgs; [nerd-fonts.terminess-ttf pkgs.terminus_font];

    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    i18n.defaultLocale = "ru_RU.UTF-8";
    i18n.extraLocales = ["ru_RU.UTF-8/UTF-8" "en_US.UTF-8/UTF-8"];
    console = {
      useXkbConfig = true;
      earlySetup = true;
      font = "cyr-sun16";
      packages = [pkgs.powerline-fonts];
    };
    services.xserver.xkb.layout = "us,ru";
    services.xserver.xkb.options = "grp:alt_shift_toggle";
    networking.hostName = "nixos";
    time.timeZone = "Europe/Moscow";

    security.pam.services.gdm.enableGnomeKeyring = true;
    security.rtkit.enable = true;

    services.timesyncd.enable = true;

    users.users = {
      mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
      };
    };
    users.defaultUserShell = pkgs.zsh;
    programs.zsh.enable = true;

    networking.firewall = {
      enable = true;
      extraCommands = ''
        # Allow ALL traffic from local network
        iptables -I INPUT 1 -s 192.168.0.0/16 -j ACCEPT
        ip6tables -I INPUT 1 -s fd00::/8 -j ACCEPT
        ip6tables -I INPUT 1 -s fe80::/10 -j ACCEPT
      '';
    };
    environment.variables = {
      PATH = builtins.getEnv "PATH" + ":~/.local/bin";
    };

    services.openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
      };
    };

    programs.mtr.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    system.stateVersion = "25.11";
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

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "sd_mod"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    fileSystems."/" = {
      device = "/dev/mapper/c3";
      fsType = "btrfs";
      options = ["subvol=nixos"];
    };

    boot.initrd.luks.devices = {
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

    fileSystems."/home" = {
      device = "/dev/mapper/c3";
      fsType = "btrfs";
      options = ["subvol=home"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/f6286dc8-eea4-4662-b92a-b2ea0992d6ca";
      fsType = "ext4";
    };

    fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/363C-6B10";
      fsType = "vfat";
      options = ["fmask=0022" "dmask=0022"];
    };

    swapDevices = [
      {device = "/dev/mapper/swap";}
    ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}

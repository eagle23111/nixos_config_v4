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
        self.nixosModules.osu

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
    nix.package = pkgs.lix;
    boot = {
      extraModprobeConfig = ''
        options hid_apple fnmode=0
      '';

      loader = {
        efi = {
          canTouchEfiVariables = true;
          efiSysMountPoint = "/boot/efi";
        };
        grub = {
          enable = true;
          efiSupport = true;
          device = "nodev";
        };
        timeout = 0;
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
      ];
    };

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = ["root" "@wheel"];
      };
      channel.enable = false;
    };

    #boot.kernelPackages = pkgs.linuxPackages_latest;

    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [nerd-fonts.terminess-ttf pkgs.terminus_font];
    };

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

    security = {
      pam.services.gdm.enableGnomeKeyring = true;
      rtkit.enable = true;
    };

    users = {
      users.mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
      };
      defaultUserShell = pkgs.zsh;
    };

    programs = {
      zsh.enable = true;
      mtr.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };

    environment = {
      systemPackages = [self.inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien];
      variables.PATH = builtins.getEnv "PATH" + ":~/.local/bin";
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

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
    nixpkgs.config.allowUnfree = true;
    nix.package = pkgs.lix;



    # Required by OpenTabletDriver
    hardware.uinput.enable = true;
    boot.kernelModules = ["uinput"];

    services.usbmuxd.enable = true;

    boot = {
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

    boot.kernelPackages = pkgs.linuxPackages_latest;

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


    users = {
      users.mortal = {
        isNormalUser = true;
        extraGroups = ["wheel" "docker" "gamemode" "libvirtd" "kvm" "wireshark" "video" "i2c"];
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
    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;

    programs.direnv.enable = true;

    environment = {
      systemPackages = [self.inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien];
      variables.PATH = builtins.getEnv "PATH" + ":~/.local/bin";
    };

    system.stateVersion = "26.05";
  };

  flake.nixosModules.laptopHardware = { config, lib, pkgs, modulesPath, ... }:
  {
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd"];
    };

  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/3b92a947-0b7c-4908-a76e-a6ba62a6a625";
  boot.initrd.luks.devices."cryptswap".device = "/dev/disk/by-partlabel/swap";

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/310b3bc6-c04f-40e6-bf96-6e18f1fdca25";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/mapper/cryptroot";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd"];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/488E-6B62";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  swapDevices =
    [ { device = "/dev/mapper/cryptswap"; }
    ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
};

}

{inputs, ...}: {
  flake.nixosModules.consoleUtils = {pkgs, ...}: {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [nerd-fonts.terminess-ttf pkgs.terminus_font];
    };

    environment.systemPackages = with pkgs; [
      which
      tree
      wget
      inputs.nvchad4nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      btop
      iotop
      iftop
      strace
      ltrace
      lsof
      nix-index
      zip
      unzip
      xz
      p7zip
      lm_sensors
      ethtool
      pciutils
      usbutils
      aria2
      fastfetch
      inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default
      #wireshark
      nil

      comma

      git
    ];
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

    programs = {
      zsh.enable = true;
      mtr.enable = true;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
    programs.direnv.enable = true;

    programs.nh = {
      enable = true;
      clean.enable = false;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };
  };
}

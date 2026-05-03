{inputs, ...}: {
  flake.nixosModules.consoleUtils = {pkgs, ...}: {
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
      wireshark
      nil

      comma
    ];

    programs.nh = {
      enable = true;
      clean.enable = false;
      clean.extraArgs = "--keep-since 4d --keep 3";
    };
  };
}

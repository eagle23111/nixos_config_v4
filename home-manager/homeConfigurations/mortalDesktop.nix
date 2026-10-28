{
  inputs,
  self,
  ...
}: {
  flake.homeModules."mortal@desktop" = {...}: {
    home = {
      username = "mortal";
      homeDirectory = "/home/mortal";
    };

    imports = [
      self.homeModules.zsh
      #self.homeModules.hyprland
      self.homeModules.mortalDesktopModule
      self.homeModules.zen-browser

      self.homeModules.essentials
    ];
  };

  flake.homeConfigurations."mortal@desktop" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      self.stylix.homeModules.stylix
      self.homeModules."mortal@desktop"
    ];
  };

  flake.homeModules.mortalDesktopModule = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      hydrus
      #inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hydownloader
      osu-lazer-bin
      #librewolf
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ryujinxCanary
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.gamesentenceminer
    ];

    nixpkgs.overlays = [
      (final: prev: {
        python3Packages =
          prev.python3Packages
          // {
            show-in-file-manager = prev.python3Packages.show-in-file-manager.overrideAttrs (old: {
              src = prev.fetchFromGitHub {
                owner = "damonlynch";
                repo = "showinfilemanager";
                rev = "v1.1.6";
                hash = "sha256-Ku9zT6NIjmiRyXmUDJK3/77wn2H2ZvcWnS5MKeHMdCM=";
              };

              nativeBuildInputs =
                (old.nativeBuildInputs or [])
                ++ [
                  prev.python3Packages.hatchling
                  prev.python3Packages.hatch-argparse-manpage
                ];
            });
          };
      })
    ];

    programs.prismlauncher = {
      enable = true;
      package = pkgs.prismlauncher.override {
        jdks = [pkgs.temurin-bin-25];
      };

      settings = {
        AutoConnect = false;
        CheckForUpdates = false;
      };
    };
    programs.lutris.enable = true;
    programs.chromium.enable = true;

    systemd.user.startServices = "sd-switch";

    home.stateVersion = "26.05";
  };
}

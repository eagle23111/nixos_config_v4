{
  inputs,
  self,
  ...
}: {
  flake.homeConfigurations."mortal@desktop" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      self.homeModules.zsh
      self.homeModules.stylix
      self.homeModules.mimeApps
      self.homeModules.mortalDesktopModule
      {
        home = {
          username = "mortal";
          homeDirectory = "/home/mortal";
        };
      }
    ];
  };

  flake.homeModules.mortalDesktopModule = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      vscode

      tor
      tor-browser

      libreoffice-fresh

      # openssl

      llama-cpp
      lmstudio

      inputs.nvchad4nix.packages.${pkgs.stdenv.hostPlatform.system}.default
      hydrus
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hydownloader

      evolution

      ani-cli
      mpv
      devenv
      firefox

      osu-lazer-bin
    ];
    programs.lutris.enable = true;

    programs.chromium.enable = true;
    programs.kitty = {
      enable = true;
      extraConfig = ''
        copy_on_select yes
        mouse_map right press ungrabbed,grabbed paste_from_selection
      '';
    };

    programs.home-manager.enable = true;
    programs.git = {
      enable = true;
      lfs.enable = true; # for huggingface
      settings = {
        user = {
          name = "eagle23111";
          email = "stasapohta@yandex.ru";
        };
      };
    };

    systemd.user.startServices = "sd-switch";

    home.stateVersion = "26.05";
  };
}

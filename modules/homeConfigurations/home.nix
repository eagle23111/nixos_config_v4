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
      self.homeModules.mortalModule
      {
        home = {
          username = "mortal";
          homeDirectory = "/home/mortal";
        };
      }
    ];
  };

  flake.homeModules.mortalModule = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      steam
      #protonup-qt
      gamemode
      gamescope
      prismlauncher
      inputs.zen-browser.packages.${system}.default
      wineWowPackages.stable
      winetricks
      vscode

      tor
      tor-browser

      libreoffice-fresh

      devenv
      openssl

      llama-cpp
      lmstudio

      inputs.nvchad4nix.packages.${system}.default
      inputs.nixpkgs-unstable.legacyPackages.${pkgs.system}.hydrus

      evolution

      ani-cli
      mpv
      devenv
      firefox
    ];
    programs.lutris = {
      enable = true;
    };
    programs.chromium.enable = true;
    programs.kitty = {
      enable = true;
      extraConfig = ''
        copy_on_select yes
        mouse_map right press ungrabbed,grabbed paste_from_selection
      '';
    };

    programs.home-manager.enable = true;
    services.gnome-keyring.enable = true;
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

    home.stateVersion = "25.11";
  };
}

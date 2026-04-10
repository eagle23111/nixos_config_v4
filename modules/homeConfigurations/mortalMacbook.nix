{
  inputs,
  self,
  ...
}: {
  flake.homeConfigurations."mortal@macbook" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      self.homeModules.zsh
      self.homeModules.stylix
      self.homeModules.mimeApps
      self.homeModules.mortalMacbookModule
      {
        home = {
          username = "mortal";
          homeDirectory = "/home/mortal";
        };
      }
    ];
  };

  flake.homeModules.mortalMacbookModule = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      vscode

      tor
      #tor-browser

      libreoffice-fresh

      openssl

      inputs.nvchad4nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      evolution

      ani-cli
      mpv
      devenv
      firefox
    ];

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

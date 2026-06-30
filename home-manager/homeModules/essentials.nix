{inputs, ...}: {
  flake.homeModules.essentials = {pkgs, ...}: {
    imports = [
      inputs.self.homeModules.zsh
      inputs.self.homeModules.neovim
    ];

    home.packages = with pkgs; [
      vscode

      tor
      tor-browser

      libreoffice-fresh

      # inputs.nvchad4nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      ani-cli
      mpv

      opencode
    ];

    programs.anki = {
      enable = true;
      addons = [
        pkgs.ankiAddons.anki-connect
        pkgs.ankiAddons.passfail2
      ];
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
  };
}

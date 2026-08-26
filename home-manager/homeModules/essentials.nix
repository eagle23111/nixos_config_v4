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
      # inputs.nvchad4nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.mpvWithAnki

      opencode
    ];

    programs.anki = {
      enable = true;
      addons = [
        pkgs.ankiAddons.anki-connect
        #pkgs.ankiAddons.passfail2
      ];
    };
    programs.obsidian.enable = true;

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

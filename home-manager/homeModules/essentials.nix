{inputs, ...}: {
  flake.homeModules.essentials = {pkgs, ...}: {
    imports = [
      inputs.self.homeModules.zsh
    ];

    home.packages = with pkgs; [
      vscode

      tor
      tor-browser

      libreoffice-fresh

      inputs.nvchad4nix.packages.${pkgs.stdenv.hostPlatform.system}.default

      ani-cli
      mpv
      devenv

      opencode
    ];

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

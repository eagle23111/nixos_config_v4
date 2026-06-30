{inputs, ...}: {
  flake.homeModules.neovim = {pkgs, ...}: {
    programs.neovim = {
      enable = true;
    };
  };

}
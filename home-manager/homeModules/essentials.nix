{inputs, ...}:
{
  flake.homeModules.essentials = {pkgs, ...}:
  {
    imports = [
      inputs.self.homeModules.zen-browser-flake
      inputs.self.homeModules.zsh
    ];
  };
}
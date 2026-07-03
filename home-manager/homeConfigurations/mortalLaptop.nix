{
  inputs,
  self,
  ...
}: {
  flake.homeModules."mortal@laptop" = {...}: {
    home = {
      username = "mortal";
      homeDirectory = "/home/mortal";
    };

    imports = [
      inputs.nixvim.homeModules.default
      inputs.zen-browser-flake.homeModules.default

      self.homeModules.zsh
      self.homeModules.gnome
      self.homeModules.mortalLaptopModule
      #self.homeModules.chromium

      self.homeModules.essentials
      self.homeModules.icons
    ];
  };

  flake.homeConfigurations."mortal@laptop" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      self.stylix.homeModules.stylix
      self.homeModules."mortal@laptop"
    ];
  };

  flake.homeModules.mortalLaptopModule = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    systemd.user.startServices = "sd-switch";

    home.stateVersion = "26.05";
  };
}

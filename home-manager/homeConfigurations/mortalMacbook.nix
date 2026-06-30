{
  inputs,
  self,
  ...
}: {
  flake.homeModules."mortal@macbook" = {...}: {
    home = {
      username = "mortal";
      homeDirectory = "/home/mortal";
    };

    imports = [
      self.homeModules.zsh
      self.homeModules.gnome
      self.homeModules.mortalLaptopModule
      #self.homeModules.zen-browser

      self.homeModules.essentials
    ];
  };

  flake.homeConfigurations."mortal@macbook" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-linux;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      self.stylix.homeModules.stylix
      self.homeModules."mortal@laptop"
    ];
  };

  flake.homeModules.mortalMacbookModule = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    systemd.user.startServices = "sd-switch";

    home.stateVersion = "26.05";
  };
}

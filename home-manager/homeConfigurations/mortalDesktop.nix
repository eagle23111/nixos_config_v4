{
  inputs,
  self,
  ...
}: {
  flake.homeModules."mortal@desktop" = {...}: {
    home = {
      username = "mortal";
      homeDirectory = "/home/mortal";
    };

    imports = [
      inputs.nixvim.homeModules.default
      inputs.zen-browser-flake.homeModules.default

      self.homeModules.zsh
      self.homeModules.gnome
      self.homeModules.mortalDesktopModule
      self.homeModules.zen-browser

      self.homeModules.essentials
    ];
  };

  flake.homeConfigurations."mortal@desktop" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      self.stylix.homeModules.stylix
      self.homeModules."mortal@desktop"
    ];
  };

  flake.homeModules.mortalDesktopModule = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      (llama-cpp.override {cudaSupport = true;})
      lmstudio
      hydrus
      #inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.hydownloader
      osu-lazer-bin
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.ryujinxCanary
    ];

    programs.lutris.enable = true;
    programs.chromium.enable = true;

    systemd.user.startServices = "sd-switch";

    home.stateVersion = "26.05";
  };
}

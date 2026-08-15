{inputs, ...}: {
  flake.nixosModules.hyprland = {pkgs, ...}: {
    imports = [
      inputs.noctalia.nixosModules.default
      # inputs.self.homeModules."gnome@extensions"
    ];

    programs.hyprland.enable = true;

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    services.flatpak.enable = true;
    services.displayManager.gdm.enable = true;
  };
}

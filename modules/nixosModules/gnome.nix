{...}: {
  flake.nixosModules.gnome = {pkgs, ...}: {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;
  };
}

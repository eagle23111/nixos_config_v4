{...}: {
  flake.nixosModules.gnome = {pkgs, ...}: {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      gnomeExtensions.blur-my-shell
      #gnomeExtensions.just-perfection
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      #gnomeExtensions.fixed-ime-list
      gnomeExtensions.static-workspace-background
      gnomeExtensions.vicinae
    ];
  };
}

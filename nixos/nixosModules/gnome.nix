{...}: {
  flake.nixosModules.gnome = {pkgs, ...}: {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    services.flatpak.enable = true;

    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [
        # mozc
        mozc-ut
      ];
    };
  };
}

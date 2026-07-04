{...}: {
  flake.nixosModules.gnome = {pkgs, ...}: {
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    environment.gnome.excludePackages = with pkgs; [
      atomix # puzzle game
      cheese # webcam tool
      epiphany # web browser
      geary # email reader
      gedit # text editor
      gnome-music
      gnome-photos
      gnome-terminal
      gnome-tour
      hitori # sudoku game
      iagno # go game
      tali # poker game
      totem # video player
      gnome-software
      gnome-calculator
      gnome-characters
    ];

    services.gnome.games.enable = false;

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

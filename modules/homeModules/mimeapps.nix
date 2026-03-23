{
  pkgs,
  inputs,
  ...
}: {
  flake.homeModules.mimeApps = {pkgs, ...}: {
    home.packages = with pkgs; [
      nautilus
      gthumb
      gedit
      evince
      inputs.zen-browser.packages.${pkgs.system}.default
      kitty
      xfce.thunar
    ];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = [ "thunar.desktop" ];
        "application/x-gnome-saved-search" = [ "thunar.desktop" ];
        "text/plain" = ["gedit.desktop"];
        "image/jpeg" = ["org.gnome.gThumb.desktop"];
        "image/png" = ["org.gnome.gThumb.desktop"];
        "application/pdf" = ["org.gnome.Evince.desktop"];
        "x-scheme-handler/http" = ["zen.desktop"];
        "x-scheme-handler/https" = ["zen.desktop"];

        "x-scheme-handler/terminal" = [ "kitty.desktop" ];
        "x-terminal-emulator" = [ "kitty.desktop" ];
      };
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}: {
  flake.homeModules.icons = {pkgs, ...}: let
    disableDesktopFiles = files: {
      xdg.dataFile =
        lib.genAttrs
        (map (f: "applications/${f}") files)
        (_: {text = "[Desktop Entry]\nHidden=true\n";});
    };
  in {
    imports = [
      (disableDesktopFiles [
        "bluetooth-sendto.desktop"
        "org.gnome.Shell.Extensions.desktop"
        "org.gnome.baobab.desktop"
        "org.gnome.Shell.PortalHelper.desktop"
        "com.cloudflare.WarpCli.desktop"
        "org.gnome.Showtime.desktop"
        "com.cloudflare.WarpTaskbar.desktop"
        "org.gnome.SimpleScan.desktop"
        "gnome-software-local-file-metainfo.desktop"
        "org.gnome.Snapshot.desktop"
        "gcm-import.desktop"
        "gnome-software-local-file-packagekit.desktop"
        "gcm-picker.desktop"
        "gnome-sound-panel.desktop"
        "org.gnome.SystemMonitor.desktop"
        "gnome-system-monitor-kde.desktop"
        "org.gnome.ColorProfileViewer.desktop"
        "gnome-about-panel.desktop"
        "gnome-system-panel.desktop"
        "org.gnome.Connections.desktop"
        "org.gnome.Tour.desktop"
        "org.gnome.Contacts.desktop"
        "org.gnome.Weather.desktop"
        "org.gnome.Decibels.desktop"
        "org.gnome.Yelp.desktop"
        "gnome-wellbeing-panel.desktop"
        "org.gnome.Epiphany.desktop"
        "gtk3-demo.desktop"
        "org.gnome.Extensions.desktop"
        "gnome-initial-setup.desktop"
        "gtk3-icon-browser.desktop"
        "org.gnome.font-viewer.desktop"
        "gnome-keyboard-panel.desktop"
        "wine.desktop"
        "org.gnome.Maps.desktop"
        "winetricks.desktop"
        "org.gnome.Music.desktop"
        "nixos-manual.desktop"
        "yad-icon-browser.desktop"
        "org.gnome.Papers-previewer.desktop"
      ])
    ];
  };
}

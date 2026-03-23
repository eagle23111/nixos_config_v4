{pkgs, inputs,...}:
{
  flake.homeModules.mimeApps = {pkgs, ...}:
  {
  home.packages = with pkgs; [
      nautilus
      gthumb
      gedit
      evince
      inputs.zen-browser.packages.${pkgs.system}.default
  ];
  
  xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = [ "gedit.desktop" ];
        "image/jpeg" = [ "org.gnome.gThumb.desktop" ];
        "image/png" = [ "org.gnome.gThumb.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
        "x-scheme-handler/http" = [ "zen-browser.desktop" ];
        "x-scheme-handler/https" = [ "zen-browser.desktop" ];
        "inode/directory" = [ "nautilus.desktop" ];
      };
    };
  };
}
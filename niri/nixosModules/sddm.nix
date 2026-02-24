{pkgs, ...}: {
  /*
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${pkgs.sddm-astronaut}/share/sddm/themes/sddm-astronaut-theme";
    extraPackages = [ pkgs.sddm-astronaut ];
  };
  */
  services.displayManager.ly.enable = true;
  systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE"; # https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988

  #environment.systemPackages = [
  #  pkgs.kdePackages.qtmultimedia
  #];
}

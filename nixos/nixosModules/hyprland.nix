{inputs, ...}: {
  flake.nixosModules.hyprland = {pkgs, ...}:
    with pkgs.lib; let
      hyprPluginPkgs = pkgs.hyprlandPlugins;

      hyprspace-fix = hyprPluginPkgs.hyprspace.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "ImanolBarba";    
          repo = "Hyprspace";
          rev = "667f5a3a9ccba02eff8c4d97979904a7aa9f2ceb";
          hash = "sha256-P27tvgpduDsMjk9mSti4We+a3kzYWYWznZKizvnyS+Q=";
        };
      }); # TODO: kill it with fire once it get merged

      hypr-plugin-dir = pkgs.symlinkJoin {
        name = "hyrpland-plugins";
        paths = with hyprPluginPkgs; [
          hyprspace-fix
        ];
      };
    in {
      imports = [
        inputs.noctalia.nixosModules.default
        # inputs.hyprland.nixosModules.default
        # inputs.self.homeModules."gnome@extensions"
      ];
      environment.sessionVariables = { HYPR_PLUGIN_DIR = hypr-plugin-dir; };

      environment.systemPackages = with pkgs; [
        kdePackages.dolphin
        playerctl
      ];
      

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };

      services.flatpak.enable = true;
      services.displayManager.gdm.enable = true;
    };
}

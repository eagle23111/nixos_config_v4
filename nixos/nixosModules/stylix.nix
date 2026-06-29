{pkgs, ...}: {
  flake.nixosModules.stylix = {pkgs, ...}: {
    imports = [
      imports.stylix.nixosModules.stylix
    ];

    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
  };
}

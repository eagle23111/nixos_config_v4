{inputs, ...}: {
  flake.nixosModules.qemu = {
    pkgs,
    self,
    ...
  }: let
    freerdp = pkgs.freerdp; # https://github.com/winapps-org/winapps/issues/894
  in {
    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    environment.systemPackages = with pkgs;
      [
        virt-manager
        usbredir
      ]
      ++ [
        (inputs.winapps.packages."${pkgs.stdenv.hostPlatform.system}".winapps.override {freerdp = freerdp;})
        inputs.winapps.packages."${pkgs.stdenv.hostPlatform.system}".winapps-launcher
      ];
    virtualisation.waydroid.enable = true;
  };
}

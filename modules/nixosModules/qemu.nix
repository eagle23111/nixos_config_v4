{inputs, ...}: {
  flake.nixosModules.qemu = {
    pkgs,
    self,
    ...
  }: {
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
        inputs.winapps.packages."${pkgs.system}".winapps
        inputs.winapps.packages."${pkgs.system}".winapps-launcher
      ];
    virtualisation.waydroid.enable = true;
  };
}

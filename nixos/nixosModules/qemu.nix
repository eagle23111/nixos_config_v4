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

    environment.systemPackages = with pkgs; [
      virt-manager
      usbredir
      winboat
      distrobox
    ];
    /*
      virtualisation.docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
      storageDriver = "btrfs";
    };
    */

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
    virtualisation.containers.storage.settings.storage.driver = "btrfs";
  };
}

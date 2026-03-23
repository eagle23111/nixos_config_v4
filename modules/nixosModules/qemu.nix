{inputs, ...}: {
  flake.nixosModules.qemu = {
    pkgs,
    self,
    ...
  }: let
    freerdp = pkgs.freerdp.overrideAttrs (old: {
      version = "3.22.0";
      src = pkgs.fetchFromGitHub {
        owner = "FreeRDP";
        repo = "FreeRDP";
        rev = "3.22.0";
        hash = "sha256-cJFY0v2zvbaKVINOKVZGvLozwgD7kf2ffVU9EGYBMGQ=";
      }; # https://github.com/winapps-org/winapps/issues/894
    });
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
        (inputs.winapps.packages."${pkgs.system}".winapps.override {freerdp = freerdp;}) 
        inputs.winapps.packages."${pkgs.system}".winapps-launcher
      ];
    virtualisation.waydroid.enable = true;
  };
}

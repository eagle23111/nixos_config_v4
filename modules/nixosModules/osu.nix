{...}:{

  flake.nixosModules.osu = {pkgs,...}:
  {
    hardware.opentabletdriver.enable = true;

    hardware.uinput.enable = true;
    boot.kernelModules = [ "uinput" ];

    environment.systemPackages = [pkgs.osu-lazer];
  };

}
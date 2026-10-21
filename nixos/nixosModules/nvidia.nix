{...}: {
  flake.nixosModules.nvidia = {
    pkgs,
    inputs,
    config,
    ...
  }: let
    # Build a patched patchelf locally (no global overlay).
    # This uses substituteInPlace to avoid dealing with a fetchpatch hash.
    patchelf-fixed = pkgs.patchelf.overrideAttrs (oldAttrs: {
      postPatch =
        (oldAttrs.postPatch or "")
        + ''
          substituteInPlace src/patchelf.cc \
            --replace-fail 'else if (d_tag == DT_VERNEED)' \
                           'else if (d_tag == DT_VERDEF) dyn->d_un.d_ptr = findSectionHeader(".gnu.version_d").sh_addr; else if (d_tag == DT_VERNEED)'
        '';
    });
  in {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        libva-utils
        vdpauinfo
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
        libvdpau-va-gl
        egl-wayland
        wgpu-utils
        libglvnd
        libGL
      ];
    };

    services.xserver.videoDrivers = ["nvidia"];
    boot.kernelParams = ["nvidia_drm.fbdev=1"];
    boot.kernelModules = ["nvidia-uvm"];
    environment.systemPackages = with pkgs; [
      libva-utils
      vdpauinfo
      vulkan-loader
      vulkan-tools
      vulkan-validation-layers
      libvdpau-va-gl
      egl-wayland
      wgpu-utils
      libglvnd
      nvtopPackages.full
      libGL
      #cudaPackages.cudatoolkit
      #cudaPackages.nsight_systems
    ];

    services.lact.enable = true;

    hardware.nvidia = {
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = false;

      open = true;

      nvidiaSettings = true;

      # package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
    nixpkgs.config.cudaSupport = true;
    hardware.nvidia-container-toolkit.enable = false;

    #hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.latest;

  hardware.nvidia.package =
    config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs (oldAttrs: {
      postFixup = (oldAttrs.postFixup or "") + ''
        ${patchelf-fixed}/bin/patchelf \
          --set-rpath "$(${patchelf-fixed}/bin/patchelf --print-rpath $bin/bin/nvidia-smi)" \
          $bin/bin/nvidia-smi
      '';
    });

    /*
      systemd.services.nvidia-power-limit = {
      description = "Set NVIDIA GPU power limit to 200 W";

      wantedBy = ["multi-user.target"];
      after = ["nvidia-persistenced.service"];
      wants = ["nvidia-persistenced.service"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecCondition = "${pkgs.coreutils}/bin/test -e /dev/nvidia0";
        ExecStart = "${pkgs.lib.getExe' config.hardware.nvidia.package "nvidia-smi"} -i 0 -pl 200";
      };
    };
    */
  };
}

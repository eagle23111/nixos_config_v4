{...}: {
  flake.nixosModules.nvidia = {
    pkgs,
    inputs,
    config,
    ...
  }: {
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
      cudaPackages.cudatoolkit
      cudaPackages.nsight_systems
    ];

    hardware.nvidia = {
      # forceFullCompositionPipeline = true;
      modesetting.enable = true;

      powerManagement.enable = true;
      powerManagement.finegrained = false;

      open = true;

      nvidiaSettings = true;

      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    nixpkgs.config.cudaSupport = true;
    hardware.nvidia-container-toolkit.enable = true;
  };
}

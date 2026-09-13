{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.ai = {pkgs, ...}: {
    /*
      imports = [
      inputs.comfyui-fhs.nixosModules.default
    ];
    */

    services.comfyui = {
      enable = true;
      gpuSupport = "cuda";
      cudaCapabilities = ["8.9"];
      enableManager = true;
      port = 8188;
      listenAddress = "127.0.0.1";
      dataDir = "/home/mortal/.local/share/ComfyUI";
      user = "mortal";
      group = "users";
      createUser = false;
      openFirewall = false;
      # extraArgs = [ "--lowvram" ];
      # environment = { };
    };

    environment.systemPackages =
      (with pkgs; [
        lmstudio
        inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.llama-cpp-optimized
      ])
      ++ (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
        dsh
      ]);
  };
}

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
      customNodes = {
        ComfyUI-Custom-Scripts = pkgs.fetchFromGitHub {
          owner = "pythongosssss";
          repo = "ComfyUI-Custom-Scripts";
          rev = "v1.2.5";
          hash = "sha256-...";
        };
        ComfyUI-Lora-Manager = pkgs.fetchFromGitHub {
          owner = "willmiao";
          repo = "ComfyUI-Lora-Manager";
          rev = "v1.2.1";
          hash = "sha256-...";
        };
      };
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

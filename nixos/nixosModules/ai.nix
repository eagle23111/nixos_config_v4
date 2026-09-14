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
        comfyui-image-saver = pkgs.fetchFromGitHub {
          owner = "alexopus";
          repo = "ComfyUI-Image-Saver";
          rev = "v1.24.1";
          hash = "sha256-mxz69YLYfXdcGCMR7i/otWysuGDDlQ6U3CXjy5i5W04=";
        };
        comfyui-lora-manager = pkgs.fetchFromGitHub {
          owner = "willmiao";
          repo = "ComfyUI-Lora-Manager";
          rev = "v1.2.1";
          hash = "sha256-M9dCClZbF3Q/4OrY+962EATjOqbNCDYv4oV0Su5feV8=";
        };
      };
      extraPythonPackages = ps:
        with ps; [
          natsort
        ];
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

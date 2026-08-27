{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.ai = {pkgs, ...}: {
    imports = [
      inputs.comfyui-fhs.nixosModules.default
    ];

    programs.comfyui = {
      enable = true;
      manager.enable = true;
      cuda.enable = true;
    };

    environment.systemPackages = with pkgs; [
      lmstudio
      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.llama-cpp-optimized
    ];
  };
}

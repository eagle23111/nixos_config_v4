{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    # llama-cpp with CUDA needs unfree packages.
    pkgsUnfree = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    packages.ryujinxCanary = pkgs.callPackage ./ryubing/package.nix {};
    packages.hydownloader = pkgs.callPackage ./hydownloader/package.nix {};
    packages.llama-cpp-optimized = pkgsUnfree.callPackage ./llamacpp/package.nix {};
    packages.mpvWithAnki = pkgs.callPackage ./mpv-with-anki/package.nix {};
  };
}

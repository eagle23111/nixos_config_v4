{
  withSystem,
  inputs,
  ...
}: {
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    }; # i hate nix

    packages.llama-cpp-optimized =
      (pkgs.llama-cpp.override {
        cudaSupport = true;
      }).overrideAttrs (old: {
        cmakeFlags =
          (old.cmakeFlags or [])
          ++ [
            # Required for extra KV quantisation types (q5_0, q4_1, etc.)
            "-DGGML_CUDA_FA_ALL_QUANTS=ON"
            # Set your GPU’s compute capability (89 = Ada Lovelace)
            "-DCMAKE_CUDA_ARCHITECTURES=89"
          ];
      });
  };
}

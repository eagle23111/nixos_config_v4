{
  perSystem = { pkgs, ... }: let
    # Optionally pin a specific CUDA toolkit version (e.g., cudaPackages_12)
    cudaPkgs = pkgs.cudaPackages;   # or pkgs.cudaPackages_12

    llama-cpp-optimized = (pkgs.llama-cpp.override {
      cudaSupport = true;
      cudaPackages = cudaPkgs;
    }).overrideAttrs (old: {
      cmakeFlags = (old.cmakeFlags or []) ++ [
        # Required for extra KV quantisation types (q5_0, q4_1, etc.)
        "-DGGML_CUDA_FA_ALL_QUANTS=ON"
        # Set your GPU’s compute capability (89 = Ada Lovelace)
        "-DCMAKE_CUDA_ARCHITECTURES=89"
      ];

      # Optional: if you want to test PR #26622 (CPU‑offload simplification)
      # before it’s merged, replace src with a fetch from that PR:
      # src = pkgs.fetchFromGitHub {
      #   owner = "ggml-org";
      #   repo = "llama.cpp";
      #   rev = "commit-hash-of-pr";
      #   hash = "sha256-...";
      # };
      # version = "unstable-2026-08-18";
    });

  in {
    packages.llama-cpp = llama-cpp-optimized;
  };
}
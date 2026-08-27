{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    #nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:NixOS/nixos-hardware/master";

    #zen-browser.url = "github:youwen5/zen-browser-flake";
    #zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    #nvchad4nix.url = "github:nix-community/nix4nvchad";
    #nvchad4nix.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    #nixvim.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser-flake.url = "github:0xc000022070/zen-browser-flake";

    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    comfyui-fhs.url = "github:eagle23111/nix-comfyui-fhs";

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;}
    {
      systems = ["x86_64-linux" "aarch64-linux"];
      imports = [
        (inputs.import-tree ./nixos)
        (inputs.import-tree ./home-manager)
        ./packages/default.nix

        inputs.home-manager.flakeModules.home-manager
      ];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;
      };
    };
}

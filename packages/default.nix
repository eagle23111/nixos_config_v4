{
  inputs,
  ...
}:
{
  perSystem = {
    pkgs,
    system,
    ...
  }:
  let
    lib = pkgs.lib;

    # Iteratively import every ./<name> directory as a flake package:
    # the directory name becomes the package name (packages.<name>)
    # and the package is built via pkgs.callPackage <name>/default.nix.
    importPackages = dir:
      let
        raw = builtins.readDir dir;
        # readDir returns [ { name, type }; ... ] on nix < 2.24
        # and { name = type; ... } on nix >= 2.24.
        entries =
          if builtins.isList raw
          then raw
          else
            map (n: {
              name = n;
              type = raw.${n};
            }) (builtins.attrNames raw);
      in
      lib.listToAttrs (
        lib.map (
          { name, ... }:
          {
            inherit name;
            value = pkgs.callPackage (dir + "/${name}") {};
          }
        ) (
          lib.filter (
            { name, type }:
            type == "directory"
            && builtins.pathExists (dir + "/${name}/default.nix")
          )
          entries
        )
      );
  in
  {
    # llama-cpp with CUDA pulls in unfree CUDA packages.
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    packages = importPackages ./.;
  };
}

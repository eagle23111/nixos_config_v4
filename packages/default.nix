{inputs, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    lib = pkgs.lib;
    importPackages = dir: let
      raw = builtins.readDir dir;
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
          {name, ...}: {
            inherit name;
            value = pkgs.callPackage (dir + "/${name}") {};
          }
        ) (
          lib.filter (
            {
              name,
              type,
            }:
              type
              == "directory"
              && builtins.pathExists (dir + "/${name}/default.nix")
          )
          entries
        )
      );
  in {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    packages = importPackages ./.;
  };
}

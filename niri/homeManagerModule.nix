{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./homeManagerModules/niri/niri.nix
    ./homeManagerModules/noctaliaShell.nix
  ];
}

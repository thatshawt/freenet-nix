let
  pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};
  freenetCoreAndFdev = pkgs.callPackage ./freenet-core-and-fdev.nix {};
in
pkgs.mkShellNoCC {
  packages = with pkgs; [
    freenetCoreAndFdev
  ];
}
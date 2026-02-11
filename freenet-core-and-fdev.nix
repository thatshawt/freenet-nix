{ }:
let
  pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};

  freenetSrc = pkgs.stdenv.mkDerivation rec {
    pname = "freenet-core-src";
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "freenet";
      repo = "freenet-core";
      rev = "ef77b28"; # pin this once it works
      sha256 = "sha256-cm7FvrJIDj6BxgNvYF8i2U0vbIZ/E/O7D1VJifdxVPo=";
      fetchSubmodules = true;
    };
    installPhase = ''
      cp -r . $out
    '';
  };

  freenetCore = pkgs.rustPlatform.buildRustPackage rec {
    pname = "freenet-core";
    version = "git";

    nativeBuildInputs = [
      pkgs.git
    ];

    src = freenetSrc;

    cargoBuildFlags = [
      "--package"
      "freenet"
      "--bin"
      "freenet"
    ];

    doCheck = false;

    cargoHash = "sha256-WJfLOwzEVjYUwJcGlOBwK9xIyN3aYI4qqF45bEtvyHo=";

    installPhase = ''
      runHook preInstall
    
      mkdir -p $out/bin
      cp target/*/release/freenet $out/bin/

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Freenet core";
      homepage = "https://github.com/freenet/freenet-core";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
    };
  };

  fdev = pkgs.rustPlatform.buildRustPackage rec {
    pname = "freenet-fdev";
    version = "git";

    nativeBuildInputs = [
      pkgs.git
    ];

    src = freenetSrc;

    cargoBuildFlags = [
      "--package"
      "fdev"
      "--bin"
      "fdev"
    ];

    doCheck = false;

    cargoHash = "sha256-WJfLOwzEVjYUwJcGlOBwK9xIyN3aYI4qqF45bEtvyHo=";

    installPhase = ''
      runHook preInstall
    
      mkdir -p $out/bin
      cp target/*/release/fdev $out/bin/

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Freenet fdev";
      homepage = "https://github.com/freenet/freenet-core";
      license = licenses.gpl3Plus;
      platforms = platforms.linux;
    };
  };

in

pkgs.symlinkJoin rec {
  pname = "freenet-core-and-fdev";
  version = "0.0.1";

  paths = [ freenetCore fdev ];
}
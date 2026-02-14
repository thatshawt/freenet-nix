{
  pkgs ? import (fetchTarball("channel:nixpkgs-unstable")) {},
}:
let
  sourceCodeRevision = "8a314d8c805091e70e6287aec143c2683aeafe0f";
  sourceCodeHash256 = "sha256-152DPvK/jxjOXgCA+27DHq/d8Nsov99ilwMwq+6kj94=";
  freenetCargoHash = "sha256-Gv3+fVvdVYJ+emP7c/MZvenra9ZPDM20QtcDm8v6lm8=";
  derivationVersion = "4";

  freenetSrc = pkgs.stdenv.mkDerivation rec {
    pname = "freenet-core-src";
    version = "git";
    src = pkgs.fetchFromGitHub {
      owner = "freenet";
      repo = "freenet-core";
      rev = sourceCodeRevision;
      sha256 = sourceCodeHash256;
      fetchSubmodules = true;
    };

    buildPhase = ''
      # disable auto-update.
      substituteInPlace crates/core/src/bin/commands/auto_update.rs \
        --replace "UpdateCheckResult::UpdateAvailable(latest)" "UpdateCheckResult::Skipped"
    '';

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

    cargoHash = freenetCargoHash;

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

    cargoHash = freenetCargoHash;

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
  version = derivationVersion;

  paths = [ freenetCore fdev ];
}
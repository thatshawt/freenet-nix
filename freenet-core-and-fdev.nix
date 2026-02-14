{
  pkgs ? import (fetchTarball("channel:nixpkgs-unstable")) {},
}:
let
  sourceCodeRevision = "1e2a37e5047c079e44d3246db1176dacce273ba5";
  sourceCodeHash256 = "sha256-iVVkp3FZSbeejcRVXLctCdiAX6y8bmaPnsw8Xw5FLP4=";
  freenetCargoHash = "sha256-Gv3+fVvdVYJ+emP7c/MZvenra9ZPDM20QtcDm8v6lm8=";
  derivationVersion = "5";

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
{
  pkgs ? import (fetchTarball("channel:nixpkgs-unstable")) {},
}:
let
  sourceCodeRevision = "ed1f298f4c6a84ad65b5bcbcadfee40095d0a334";
  sourceCodeHash256 = "sha256-/xU6i25GKD8JM/Q4GCasSd5Pa2BUOcrE+EqScKfdBqQ=";
  freenetCargoHash = "sha256-UwZiZZ5spfa+Ev2Q5qzdfzQUOS163Q49yMMYX+Eojdg=";
  derivationVersion = "6";

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

      # disable update.
      substituteInPlace crates/core/src/bin/commands/update.rs \
        --replace "self.download_and_install(&latest).await" "return Ok(());"
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
{
  pkgs ? import (fetchTarball("channel:nixpkgs-unstable")) {},


}:
let
  sourceCodeRevision = "HEAD";
  sourceCodeHash256 = "sha256-MX98tWWK34S2AiFSL45ds2en0v/cPsPnHUKuzQZr+sY=";
  freenetCargoHash = "sha256-50gbfDUVx4FRkOwnuOngd3tpKvBJgx+3AMjHBccu4xk=";
  derivationVersion = "0.2";

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
# {
#   lib
# }:

let
  # pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};
  pkgs = import (<nixpkgs>) {};
  freenetCoreAndFdev = pkgs.callPackage ./freenet-core-and-fdev.nix {};

  BASE_DIR="/root/.cache/freenet";
  NODE_DIR="${BASE_DIR}/node";
  WS_API_PORT="7509";
in

pkgs.dockerTools.buildImage {
  name = "freenet-docker-node";

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    mkdir -p ${BASE_DIR}
    mkdir -p ${NODE_DIR}
  '';

  # copyToRoot = pkgs.buildEnv {
  #   name = "image-root";
  #   paths = [ freenetCoreAndFdev ];
  #   pathsToLink = [ "/bin" ];
  # };
  # copyToRoot = [ freenetCoreAndFdev ];

  config = {
    Cmd = [
      "${freenetCoreAndFdev}/bin/freenet" "network"
      "--config-dir" "${BASE_DIR}"
      "--data-dir" "${NODE_DIR}"
      "--ws-api-port" "${WS_API_PORT}"
    ];

    Env = [
      "RUST_BACKTRACE=1"
      "RUST_LOG=\"freenet=debug,freenet-stdlib=debug,fdev=debug\""
    ];

    ExposedPorts = {
      "${WS_API_PORT}" = {};
    };

    # do we need this?
    Volumes = {
      "${BASE_DIR}" = {};
      "${NODE_DIR}" = {};
    };
  };
  
}
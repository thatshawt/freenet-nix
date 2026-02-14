{
  # here i put <nixpkgs> instead of doing "channel:nixpkgs-unstable" is because it didnt work that way :P
  pkgs ? import (<nixpkgs>) {},
}:

let
  latestPkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};
  freenetCoreAndFdev = pkgs.callPackage ./freenet-core-and-fdev.nix {
    pkgs = latestPkgs;
  };

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

  # got this information from the freenet-core repository in the docker folder
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
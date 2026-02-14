# freenet-core-and-fdev.nix
`freenet-core-and-fdev.nix` outputs a `freenet` binary and an `fdev` binary.

the approach used to packaging freenet is to compile `freenet` and `fdev` using `pkgs.rustPlatform.buildRustPackage`. auto-updates are disabled because it doesnt work in the case of nix. updates will have to be done by changing the `sourceCodeRevision`, `sourceCodeHash256`, and `freenetCargoHash` variables at the top of `freenet-core-and-fdev.nix` and rebuilding im guessing.

to rebuild i usually do `time nix-build freenet-core-and-fdev.nix`.

# docker-image-freenet-node.nix
`docker-image-freenet-node.nix` is an example of a working docker container that runs the `freenet` package as a node.

to use it you first have to build it using something like `nix-build docker-image-freenet-node.nix` and then you load the resulting image into docker like so: `sudo docker load < result`. then after loading it into docker you run it like so: `sudo docker run --network host NameGoesHere`. when the docker container is running you will have a freenet delegate running on your computer at the specified port in `docker-image-freenet-node.nix` which is 7509 by default.

now you try out going to river, for example, and seeing if that loads.

i didnt set up any persistance with the container so your gonna have to set up a volume for that or something so you dont lose your delegate data every time you stop the container. to do that you just need to bind a volume to the container's "/root/.cache/freenet" path, in theory.

# shell.nix
`shell.nix` is an example of how to use this for creating an environment with the package.
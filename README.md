`freenet-core-and-fdev.nix` output `freenet` and `fdev` binaries.

the approach used to packaging freenet is to compile `freenet` and `fdev` using `pkgs.rustPlatform.buildRustPackage`. auto-updates are disabled because it doesnt work in the case of nix. updates will have to be done by changing the `sourceCodeRevision`, `sourceCodeHash256`, and `freenetCargoHash` variables at the top of `freenet-core-and-fdev.nix` and rebuilding im guessing.

`shell.nix` is there as an example i suppose.
{
  description = "Nix template for incremental builds in Haskell";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    nixos-unified.url = "github:srid/nixos-unified";
    haskell-flake.url = "github:srid/haskell-flake";

    # Follows `inputs.self` by default
    #
    # When `--override-input prev <older-revision-of-current-flake>` is used,
    # `self.pacakges.<system>.default` uses `prev.packages.<system>.default`'s build artifacts to build incrementally
    prev.follows = "";
  };

  outputs = inputs:
    # This will import ./nix/modules/flake/*.nix
    # cf. https://nixos-unified.org/autowiring.html#flake-parts
    #
    # To write your own Nix, add or edit files in ./nix/modules/flake/
    inputs.nixos-unified.lib.mkFlake
      { inherit inputs; root = ./.; };
}

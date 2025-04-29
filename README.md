# haskell-incremental-build-template

> [!IMPORTANT]
> This minimal template focuses solely on incremental Haskell build configuration with Nix.
> For a more batteries-included Haskell Nix template, combine it with <https://github.com/srid/haskell-template>

A template for incremental Haskell builds using Nix, leveraging [nixpkgs’s Haskell incremental build system](https://github.com/NixOS/nixpkgs/blob/30a7bc1176cd9cd066cd75b9339872fa985a6379/doc/languages-frameworks/haskell.section.md?plain=1#L469-L515) and [haskell-flake]

## Getting Started

For an existing Haskell project already using [haskell-flake], integrate this template by:
- Add the `prev` flake input (see [flake.nix](./flake.nix)).

https://github.com/juspay/haskell-incremental-build-template/blob/7432331400f27924d827fbf81de5140c1fa0052c/flake.nix#L10-L14

- Include settings from [haskell.nix](./nix/modules/flake/haskell.nix):

https://github.com/juspay/haskell-incremental-build-template/blob/7432331400f27924d827fbf81de5140c1fa0052c/nix/modules/flake/haskell.nix#L20-L32

- Adopt the CI workflow from [ci.yaml](./.github/workflows/ci.yaml).

[haskell-flake]: https://github.com/srid/haskell-flake

## Quick Trial

- Clone the repository: `git clone https://github.com/juspay/haskell-incremental-build-template && cd haskell-incremental-build-template`
- Perform a full build: `nix build .#default -L`
  - This builds both `Example.hs` and `Main.hs` modules.
- Add a newline to `Main.hs` to simulate a change: `echo >> src/Main.hs`
- Perform an incremental build: `nix build .#default --override-input prev github:juspay/haskell-incremental-build-template -L`
  - Only `Main.hs` is rebuilt.

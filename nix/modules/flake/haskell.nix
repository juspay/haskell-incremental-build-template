{ root, inputs, ... }:
{
  imports = [
    inputs.haskell-flake.flakeModule
  ];
  perSystem = { self', inputs', lib, config, pkgs, ... }: {
    haskellProjects.default = {
      # To avoid unnecessary rebuilds, we filter projectRoot:
      # https://community.flake.parts/haskell-flake/local#rebuild
      projectRoot = builtins.toString (lib.fileset.toSource {
        inherit root;
        fileset = lib.fileset.unions [
          (root + /src)
          (root + /haskell-incremental-build-template.cabal)
          (root + /LICENSE)
          (root + /README.md)
        ];
      });

      settings = {
        haskell-incremental-build-template = {
          installIntermediates = true;
        };
      };
      autoWire = [ ];
    };
    packages.default =
      pkgs.haskell.lib.compose.overrideCabal
        (drv: {
          previousIntermediates = if inputs.prev != inputs.self then inputs'.incremental.packages.default else null;
        })
        config.haskellProjects.default.outputs.finalPackages.haskell-incremental-build-template;
  };
}

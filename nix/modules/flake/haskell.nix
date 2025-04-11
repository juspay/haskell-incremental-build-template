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
          # TODO: Enable `separateIntermediatesOutput` after https://github.com/srid/devour-flake/issues/31 is fixed
        };
      };

      # We don't autoWire the flake outputs to prevent [om ci](https://omnix.page/om/ci.html) from building them. 
      # Instead, we have `packages.default` (see below) that conditionally does incremental or full build.
      autoWire = [ ];
    };
    packages.default =
      pkgs.haskell.lib.compose.overrideCabal
        (drv: {
          # NOTE: `inputs.prev != inputs.self` is a very loose check and expects the user
          # to do the right thing when overriding `prev`
          previousIntermediates = if inputs.prev != inputs.self then inputs'.prev.packages.default else null;
        })
        config.haskellProjects.default.outputs.finalPackages.haskell-incremental-build-template;
  };
}

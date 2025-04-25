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
          # NOTE: `inputs.prev != inputs.self` is a very loose check and expects the user
          # to do the right thing when overriding `prev`
          previousIntermediates =
            if inputs.prev != inputs.self then
              inputs'.prev.packages.default
            else null;
          # TODO: Enable `separateIntermediatesOutput` after https://github.com/srid/devour-flake/issues/31 is fixed
        };
      };
    };

    packages.default = self'.packages.haskell-incremental-build-template;
  };
}

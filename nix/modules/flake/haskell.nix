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

    packages = lib.mkMerge [
      (lib.mkIf (inputs.incremental == inputs.self) {
        default = config.haskellProjects.default.outputs.finalPackages.haskell-incremental-build-template;
      })
      (lib.mkIf (inputs.incremental != inputs.self) {
        incremental =
          pkgs.haskell.lib.compose.overrideCabal
            (drv: {
              previousIntermediates = inputs'.incremental.packages.default;
            })
            config.haskellProjects.default.outputs.finalPackages.haskell-incremental-build-template;
      })
    ];

  };
}

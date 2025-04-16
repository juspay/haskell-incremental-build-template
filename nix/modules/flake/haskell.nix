{ root, inputs, ... }:
{
  imports = [
    inputs.haskell-flake.flakeModule
  ];
  perSystem = { self', inputs', lib, config, pkgs, ... }: {
    haskellProjects.default = {
      settings = {
        haskell-incremental-build-template = {
          installIntermediates = true;
          separateIntermediatesOutput = true;
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
              previousIntermediates = inputs'.incremental.packages.default.intermediates;
            })
            config.haskellProjects.default.outputs.finalPackages.haskell-incremental-build-template;
      })
    ];

    # Default package & app.
    # incremental = 
    #   pkgs.haskell.lib.compose.overrideCabal 
    #     (drv: {
    #       previousIntermediates = inputs'.incremental.packages.default.intermediates;
    #     }) 
    #   config.haskellProjects.default.outputs.finalPackages.haskell-incremental-build-template;

  };
}

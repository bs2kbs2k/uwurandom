{
  description = "Like /dev/urandom, but objectively better";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let

      # to work with older version of flakes
      lastModifiedDate = self.lastModifiedDate or self.lastModified or "19700101";

      # Generate a user-friendly version number.
      version = builtins.substring 0 8 lastModifiedDate;

      # System types to support.
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in

    {
      
      nixosModules.uwurandom =
        { pkgs, config, ... }:
        let
          kernel = config.boot.kernelPackages.kernel;
        in
        {
          nixpkgs.overlays = [
            final: prev: {

              uwurandom = with final; stdenv.mkDerivation rec {
                name = "uwurandom-${version}-${kernel.version}";

                src = ./.;

                sourceRoot = "source/";
                hardeningDisable = [ "pic" "format" ];
                nativeBuildInputs = kernel.moduleBuildDependencies;

                makeFlags = [
                  "KERNELRELEASE=${kernel.modDirVersion}"
                  "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
                  "INSTALL_MOD_PATH=$(out)"
                ];
              };

            }
          ];

          boot.extraModulePackages = [ pkgs.uwurandom ];
        };

    };
}

{
  description = "Like /dev/urandom, but objectively better";

  # Nixpkgs / NixOS version to use.
  inputs.nixpkgs.url = "nixpkgs/nixos-22.11";

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

      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });

    in

    {
      overlay = final: prev: {

        uwurandom = { kernel }: with final; stdenv.mkDerivation rec {
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

      };

      # Provide some binary packages for selected system types.
      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) uwurandom;
        });

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.

      nixosModules.uwurandom =
        { pkgs, config, ... }:
        let
          kernel = config.boot.kernelPackages.kernel;
        in
        {
          nixpkgs.overlays = [ self.overlay ];

          boot.extraModulePackages = [ ( pkgs.uwurandom { kernel = config.boot.kernelPackages.kernel; } ) ];
        };

    };
}

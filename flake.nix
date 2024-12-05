{
  description = "cross-compile the sd-image-arm7 on x86_64-linux to arm7-multiplatform";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {

    overlays = [ (final: prev: {
      efivar = import ./efivar-fixed.nix {
        inherit (final) lib stdenv buildPackages fetchFromGitHub pkg-config popt;
      };
    }) ];

    nixosConfigurations.generic_arm7 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ pkgs, lib, modulesPath, ... }: {
          nixpkgs = {
            crossSystem = lib.systems.examples.armv7l-hf-multiplatform;
            overlays = self.overlays;
          };

          imports = [ "${modulesPath}/installer/sd-card/sd-image-armv7l-multiplatform.nix" ];

          boot.supportedFilesystems.zfs = lib.mkForce false;
#          boot.loader.systemd-boot.enable = false;  # Disable systemd-boot to avoid EFI dependencies

          users.mutableUsers = false;
          users.users.root = {
            password = "root";
          };
          users.users.user = {
            password = "user";
            isNormalUser = true;
            extraGroups = [ "wheel" ];
          };

          system.stateVersion = "24.11";
        })
      ];
    };

    packages.x86_64-linux.default = self.nixosConfigurations.generic_arm7.config.system.build.sdImage;
  };
}

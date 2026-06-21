{
  description = "s4m8 NixOS Flake — hexbox + box";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, agenix, quickshell, ... }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    mkHost = hostname: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit pkgs-unstable; };
      modules = [
        ./configuration.nix
        ./hosts/${hostname}/hardware-configuration.nix
        ./hosts/${hostname}/base.nix
        ./hosts/${hostname}/modules.nix
        agenix.nixosModules.age
        {
          age.identityPaths = [ "/etc/age/keys.txt" "/home/s4m8/.config/age/key.txt" ];
        }
        ./modules/system/secrets.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.s4m8 = import ./hosts/${hostname}/home.nix;
            extraSpecialArgs = { inherit quickshell pkgs-unstable; };
            backupFileExtension = "backup";
          };
        }
      ];
    };
  in {
    nixosConfigurations = {
      hexbox = mkHost "hexbox";
      box = mkHost "box";
    };

    devShells.${system}.default = pkgs-unstable.mkShell {
      packages = [ agenix.packages.${system}.agenix ];
    };
  };
}

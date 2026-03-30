# ~/.my-nixos-config-btw/flake.nix
{
  description = "ratz`s nixos-btw";

  inputs = {
    # Main nixpkgs with unstable channel (matches your 26.05 system)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Keep stable as a fallback if needed
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";

    #nixcord
    nixcord.url = "github:FlameFlag/nixcord";

    #nix-gc
    nix-gc-env.url = "github:Julow/nix-gc-env";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixcord, nix-gc-env, ... }@inputs: {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        pkgs-stable = import nixpkgs-stable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        nixcord.nixosModules.nixcord
        nix-gc-env.nixosModules.default

        ./configuration.nix
        ./hardware-configuration.nix


      ];
    };
  };
}

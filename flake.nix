# ~/.my-nixos-config-btw/flake.nix
{
  description = "ratz`s nixos-btw";

  inputs = {
    # Main nixpkgs with unstable channel (matches your 26.05 system)
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Keep stable as a fallback if needed
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, ... }@inputs: {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        # Make stable packages available with pkgs-stable
        pkgs-stable = import nixpkgs-stable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        # Your main system configuration
        ./configuration.nix
        ./nixcord.nix
        ./hardware-configuration.nix
      ];
    };
  };
}

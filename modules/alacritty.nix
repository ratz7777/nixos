{ config, pkgs, ... }:

{
  # Enable the Alacritty program in home-manager
  programs.alacritty.enable = true;

  # Define your Alacritty settings using a Nix attribute set.
  # The options generally mirror the structure of Alacritty's
  # TOML/YAML configuration file.
  programs.alacritty.settings = {
    # Example settings:
    font = {
      size = 12.0;
      normal = {
        family = "Terminus";
        style = "Regular";
      };
    };
    colors = {
      primary.background = "0x181818";
      normal.red = "0xab4642";
      # Add other colors...
    };
    live_config_reload = true; # Enable live reloading
    # Add key bindings, etc.
  };

  # Optional: ensure the package is installed
  home.packages = [
    pkgs.alacritty
  ];

  # Set the home.stateVersion appropriate for your NixOS version
  home.stateVersion = "24.11"; # Replace with your version
}

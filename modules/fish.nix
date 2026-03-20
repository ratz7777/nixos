{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ fish ];

    # Enable fish configuration options if desired (optional, but useful for features like man-page completions)
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
    set -g fish_greeting ""
  '';
  };
  # Add fish to the list of globally available shells
  environment.shells = with pkgs; [ fish bash ];

  # Optional: Set the default shell for all users
  users.defaultUserShell = pkgs.fish; #
  # Or, if you have a config file in your dotfiles repository:
  # environment.etc."alacritty/alacritty.toml".source = ./dotfiles/alacritty.toml;
}

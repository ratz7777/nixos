{ config, pkgs, nix-gc-env, ... }:

{
  # Keep only 5 most recent generations, run daily
  nix.gc = {
    automatic = true;
    dates = "daily";           # Changed from "weekly" to "daily"
    delete_generations = "+5"; # Keeps the 5 most recent generations
  };
}

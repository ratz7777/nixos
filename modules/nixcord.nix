# packages.nix
{ config, pkgs, pkgs-stable, ... }: {
  programs.nixcord = {
    enable = true;
    config = {
        pugins = {
            fakeNitro.enable = true;
        };
    };
  };
};

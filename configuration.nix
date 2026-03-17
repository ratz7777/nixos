# /etc/nixos/configuration.nix
{ config, lib, pkgs, inputs, pkgs-stable, ... }:

{

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  services.printing = {
  enable = true;
  drivers = [pkgs.hplipWithPlugin];
  };

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Network configuration
  networking = {
    hostName = "nixos-btw";
    networkmanager.enable = true;
  };

  # Time and locale
  time.timeZone = "Europe/Moscow";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "ru_RU.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
    extraLocaleSettings = {
      LC_TIME = "ru_RU.UTF-8";
      LC_MONETARY = "ru_RU.UTF-8";
      LC_MEASUREMENT = "ru_RU.UTF-8";
      LC_ADDRESS = "ru_RU.UTF-8";
      LC_NAME = "ru_RU.UTF-8";
      LC_PAPER = "ru_RU.UTF-8";
      LC_TELEPHONE = "ru_RU.UTF-8";
    };
  };

  # Graphics and NVIDIA
  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      open = false;  # Using proprietary drivers
      # Uncomment if you want specific package
      # package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  # Display Manager and Desktop Environment
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    desktopManager.plasma6.enable = true;
    displayManager.ly.enable = true;
    displayManager.ly.settings = {
        xsessions = "";
        default_input = "password";
    };


    # Enable Flatpak
    flatpak.enable = true;
  };

  # AppImage configuration - Your working setup!
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [
        libepoxy
        zstd

      ];
    };
  };

  # Steam
  programs.steam.enable = true;

  # User accounts
  users.users.ratz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    packages = with pkgs; [
      # User-specific packages go here
    ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [

    #edu
    (python3.withPackages (ps: [ ps.tkinter ]))
    libreoffice

    # Editors and development
    neovim
    git

    # Web browser
    firefox
    librewolf

    # System utilities
    wget
    fastfetch
    htop
    btop

    # Archive utilities
    unzip
    zip
    p7zip

    # Network tools
    curl
    openssl

    # Nix utilities
    nix-output-monitor
    nix-tree

    #misc
    ncdu
    keet
    cmatrix

    discord
    vencord
  ];

  # Fonts
  fonts.packages = with pkgs; [
    terminus_font
    # Add more fonts here
    # noto-fonts
    # noto-fonts-cjk
    # noto-fonts-emoji
  ];

  # Optional: Add packages from stable channel
  # environment.systemPackages = with pkgs-stable; [
  #   # Add stable packages here
  # ];

  # System state version
  system.stateVersion = "25.11";
}

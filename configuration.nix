# /etc/nixos/configuration.nix
{ config, lib, pkgs, inputs, pkgs-stable, ... }:

{
    imports = [
      ./modules/nixcord.nix
      ./modules/nixvim.nix

      ./modules/alacritty.nix
      ./modules/fish.nix

      ./modules/openrgb.nix
      ./modules/nix-gc.nix
    ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Boot configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [ "pcie_aspm=off" ]; # Disables Active State Power ManagementpowerManagement
  fileSystems."/mnt/win11-kingston" = {
    device = "/dev/nvme1n1p3";
    fsType = "ntfs-3g";
  };

  #sound 
  # 1. Enable Realtime scheduling (critical for 96kHz+ stability)
  
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # 2. Lock the Engine to 96kHz to stop hardware switching/cracking
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 96000;
        "default.clock.allowed-rates" = [ 96000 ]; # Only one rate = No switching
        "default.clock.quantum" = 1024;            # Stable buffer size
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 2048;
      };
    };

    # 3. MiniFuse Specific Tweaks: No Sleep, Extra Headroom
    wireplumber.extraConfig."99-arturia-stable" = {
      "monitor.alsa.rules" = [
        {
          matches = [
            { "node.name" = "~alsa_output.usb-Arturia_MiniFuse_2.*"; }
          ];
          actions = {
            update-props = {
              "session.suspend-timeout-seconds" = 0; # Keep the DAC powered on
              "api.alsa.headroom" = 1024;            # Buffer against USB jitter
            };
          };
        }
      ];
    };
  };

  services.printing = {
  enable = true;
  drivers = [pkgs.hplipWithPlugin];
  };

  # Network configuration
  networking = {
    hostName = "nixos-btw";
    networkmanager.enable = true;
    useDHCP = false;
  };

  # Time and locale
  time = {
  hardwareClockInLocalTime = true;
  timeZone = "Europe/Moscow";
};
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

  # for teamspeak
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
  programs.steam = {
  enable = true;
  dedicatedServer.openFirewall = true;
};

  # User accounts
  users.users.ratz = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [

    #edu
    (python3.withPackages (ps: [ ps.tkinter ]))
    libreoffice

    # Editors and development
    helix
    vscode

    libgcc
    git

    # Web browser
    firefox

    # System utilities
    wget
    fastfetch

    # Nix utilities
    nix-output-monitor
    nix-tree

    #misc
    ncdu
    keet
    cmatrix
    qbittorrent-enhanced

    #video
    obs-studio
    vlc

    #llm
    ollama

    (makeDesktopItem {
    name = "warthunder";
    desktopName = "warthunder";
    exec = "steam-run /home/ratz/Downloads/WarThunder/launcher";
    icon = "warthunder";
    comment = "War Thunder on NixOS";
    type = "Application";
    categories = [ "Game" ];
    })

  ];

  # 2. Configure Ollama
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
  };

  #spotify network discovery, zomboid
  networking.firewall.allowedUDPPorts = [ 5353 16261 16262];
  networking.firewall.allowedTCPPorts = [ 57621 16261 16262];


  # Fonts
  fonts.packages = with pkgs; [
    terminus_font
  ];

  system.stateVersion = "25.11";
}

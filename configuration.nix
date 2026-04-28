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
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [48000 96000 192000]; # Only one rate = No switching
        "default.clock.quantum" = 1024;            # Stable buffer size
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 2048;
      };
    };

  };

  services.printing = {
  enable = true;
  drivers = [pkgs.hplipWithPlugin];
  };

  musnix.enable = true;

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

  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    desktopManager.plasma6.enable = true;

    displayManager.defaultSession = "plasmawayland";

    greetd = {
      enable = true;
      settings = {
	default_session = {
	  command = "${pkgs.tuigreet}/bin/tuigreet --remember --time --cmd startplasma-wayland";
	};
      };
    };

#    displayManager.ly.enable = true;
#    displayManager.ly.settings = {
#        xsessions = "";
#        default_input = "password";
#	default_user = "ratz";
#	save = true;
#    };


    # Enable Flatpak    
  };

  services.flatpak.enable = true;

  hardware.bluetooth.enable = true;

  systemd.services.greetd = {
    serviceConfig = {
      Type = "idle";
      StandardInput = "tty";
      StandardOutput="tty";
      StandardError="journal";
      TTYReset="true";
      TTYVHangup="true";
      TTYVTDisallocate="true";
    };
  };

  # for teamspeak
  programs.appimage = {
    enable = true;
    binfmt = true;
    package = pkgs.appimage-run.override {
      extraPkgs = pkgs: with pkgs; [
        libepoxy
        zstd
#
      ];
    };
  };

  # Steam
  programs.steam = {
  enable = true;
  dedicatedServer.openFirewall = true;
};

  # User accounts
  users.users = {
    ratz = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "audio" "seat" ];
    };
    megalis = {
     isNormalUser = true;
     extraGroups = [ "wheel" "networkmanager" "video" "audio" "seat" ];
    };
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [

    #edu
    (python3.withPackages (ps: [ ps.tkinter ]))
    libreoffice

    # Editors and development
    helix
    vscode

    nim-2_0

    libgcc
    git

    #3d printing
    orca-slicer

    # Web browser
    firefox
    chromium

    # System utilities
    wget
    fastfetch

    # Nix utilities
    nix-output-monitor
    nix-tree

    #terminal bloat
    cmatrix
    cava

    #misc
    unrar
    ncdu
    keet
    qbittorrent-enhanced

    #video
    obs-studio
    vlc

    #llm
    ollama

    #minecraft
    jdk25
    
    #chromium and code
    (makeDesktopItem {
    name = "vscode";
    desktopName = "vscode";
    exec = "env -u FONTCONFIG_FILE -u FONTCONFIG_PATH XDG_CONFIG_HOME=/home/ratz/.xdg_elecrton/ code";
    icon = "vscode";
    comment = "vscode";
    type = "Application";
    })


    #prism_minecraft
    (makeDesktopItem {
    name = "PrismLauncher";
    desktopName = "PrismLauncher";
    exec = "appimage-run /home/ratz/.prismAppimage/PrismLauncher-Linux-x86_64.AppImage";
    icon = "prism";
    comment = "minecraft launcher";
    type = "Application";
    categories = [ "Game" ];
    })

    #wt
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
  #do not run on startup
  systemd.services.ollama.wantedBy = lib.mkForce [ ];

  #spotify network discovery, zomboid
  networking.firewall.allowedUDPPorts = [ 5353 16261 16262 25565 ];
  networking.firewall.allowedTCPPorts = [ 57621 16261 16262 25565 ];


  # Fonts
  
  fonts = {
  enableDefaultPackages = true;
    fontconfig = {
       antialias = false;
       allowBitmaps = true;
       hinting = {
	 enable = true;
	 autohint = false;
	 style = "full";
	
       };
       subpixel = {
	 rgba = "rgb";
	 lcdfilter = "default";
       };
    };
  };

  fonts.packages = with pkgs; [
  terminus_font
  terminus_font_ttf

  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-color-emoji
  
  liberation_ttf
 
  fira-code
  fira-code-symbols
  
  dejavu_fonts

  dina-font
  proggyfonts
  ];

  system.stateVersion = "25.11";
}

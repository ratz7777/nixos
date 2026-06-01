{ pkgs, ... }:

let
  setKdeWallpaper = pkgs.writeShellScript "set-kde-wallpaper" ''
    # DBus needs to know where the display is when run from systemd
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    
    VAL="$1"

    ${pkgs.kdePackages.plasma-workspace}/bin/qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
      var allDesktops = desktops();
      for (var i = 0; i < allDesktops.length; i++) {
          var d = allDesktops[i];
          
          // --- OPTION A: For Solid Colors (Your original intent) ---
          d.currentConfigGroup = Array('Wallpaper', 'org.kde.color', 'General');
          d.writeConfig('Color', 'Color(' + VAL + ')'); // Fixed the 'Color_Color' typo
          
          // --- OPTION B: For actual Images (Uncomment if you want image files) ---
          // d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
          // d.writeConfig('Image', 'file://' + VAL);
          
          // Force Plasma to reload the configuration change
          d.reloadConfig();
      }
    "
  '';
in
{
  systemd.user.services = {
    set-wallpaper-morning = {
      description = "Morning wallpaper switch";
      script = "${setKdeWallpaper} '255,255,255'"; # For colors: 'R,G,B' | For images: '/path/to/light.jpg'
    };
    set-wallpaper-night = {
      description = "Night wallpaper switch";
      script = "${setKdeWallpaper} '0,0,0'";       # For colors: 'R,G,B' | For images: '/path/to/dark.jpg'
    };
  };

  systemd.user.timers = {
    set-wallpaper-morning = {
      description = "Trigger morning wallpaper";
      timerConfig = {
        OnCalendar = "*-*-* 08:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    set-wallpaper-night = {
      description = "Trigger night wallpaper";
      timerConfig = {
        OnCalendar = "*-*-* 22:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}

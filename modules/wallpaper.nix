{ pkgs, ... }:

let
  setKdeColor = pkgs.writeShellScript "set-kde-color" ''
    color="$1"
    ${pkgs.plasma-workspace}/bin/qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
      var allDesktops = desktops();
      for (var i = 0; i < allDesktops.length; i++) {
          var d = allDesktops[i];
          d.currentConfigGroup = Array('Wallpaper', 'org.kde.color', 'General');
          d.writeConfig('Color', 'Color_Color(' + color + ')');
      }
    "
  '';
in
{
  # Define user systemd timers at the system config level
  systemd.user.services = {
    set-wallpaper-white = {
      description = "Set KDE wallpaper to White";
      script = "${setKdeColor} ffffff";
    };
    set-wallpaper-black = {
      description = "Set KDE wallpaper to Black";
      script = "${setKdeColor} 000000";
    };
  };

  systemd.user.timers = {
    set-wallpaper-white = {
      description = "Morning wallpaper switch";
      timerConfig = {
        OnCalendar = "*-*-* 08:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
    set-wallpaper-black = {
      description = "Night wallpaper switch";
      timerConfig = {
        OnCalendar = "*-*-* 20:00:00";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}

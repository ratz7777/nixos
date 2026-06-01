{ pkgs, ... }:

let
  setKdeWallpaper = pkgs.writeShellScript "set-kde-wallpaper" ''
    
    ID="${pkgs.coreutils}/bin/id"
    MKTEMP="${pkgs.coreutils}/bin/mktemp"
    APPLY_WP="${pkgs.kdePackages.plasma-workspace}/bin/plasma-apply-wallpaperimage"
    MAGICK="${pkgs.imagemagick}/bin/magick"

    
    USER_ID=$($ID -u)
    export XDG_RUNTIME_DIR="/run/user/$USER_ID"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$USER_ID/bus"

    COLOR="$1" 

    
    WP_PATH="/tmp/bg_""$COLOR"".png"
    if [ ! -f "$WP_PATH" ]; then
        $MAGICK -size 1x1 xc:"$COLOR" "$WP_PATH"
    fi

    
    $APPLY_WP "$WP_PATH"
  '';
in
{
  
  environment.systemPackages = [ pkgs.imagemagick ];

  systemd.user.services = {
    set-wallpaper-day = {
      description = "day wallpaper switch";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${setKdeWallpaper} 'white'";
      };
      wantedBy = [ "plasma-plasmashell.service" ];
      after = [ "plasma-plasmashell.service" ];
    };

    set-wallpaper-night = {
      description = "Night wallpaper switch";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${setKdeWallpaper} 'black'";
      };
      wantedBy = [ "plasma-plasmashell.service" ];
      after = [ "plasma-plasmashell.service" ];
    };
  };

  systemd.user.timers = {
    set-wallpaper-day = {
      description = "Trigger day wallpaper";
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
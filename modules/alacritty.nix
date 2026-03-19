{ config, pkgs, ... }:
let
  alacrittyConfig = pkgs.writeText "alacritty.toml" ''
    [colors]
    draw_bold_text_with_bright_colors = true

    [env]
    TERM = "alacritty"

    [font]
    size = 11.0

    [font.bold]
    family = "terminus"
    style = "Bold"

    [font.bold_italic]
    family = "terminus"
    style = "Bold Italic"

    [font.italic]
    family = "terminus"
    style = "Italic"

    [font.normal]
    family = "terminus"
    style = "Regular"

    [font.offset]
    x = 0
    y = 1

    [[keyboard.bindings]]
    action = "Paste"
    key = "V"
    mods = "Control|Shift"

    [[keyboard.bindings]]
    action = "Copy"
    key = "C"
    mods = "Control|Shift"

    [[keyboard.bindings]]
    action = "IncreaseFontSize"
    key = "Plus"
    mods = "Control"

    [[keyboard.bindings]]
    action = "DecreaseFontSize"
    key = "Minus"
    mods = "Control"

    [[keyboard.bindings]]
    action = "ToggleFullscreen"
    key = "F11"

    [scrolling]
    history = 10000
    multiplier = 3

    [window]
    #decorations = "none"
    dynamic_padding = true
    startup_mode = "Windowed"
    title = "Alacritty"

    [window.padding]
    x = 0
    y = 0
  '';
in
{
  environment.systemPackages = with pkgs; [ alacritty ];

  environment.etc."alacritty.toml" = {
    text = builtins.readFile alacrittyConfig; # Method A: Using the text from above
    target = "alacritty/alacritty.toml"; # This will create /etc/alacritty/alacritty.toml
  };

  # Or, if you have a config file in your dotfiles repository:
  # environment.etc."alacritty/alacritty.toml".source = ./dotfiles/alacritty.toml;
}

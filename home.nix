{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    p7zip zip unzip
    wget arp-scan nmap
    tree btop

    postman
    nodejs cypress bun eas-cli wrangler live-server
    clang clang-tools stdenv lld gnumake cmake lldb ninja pkg-config llvmPackages.libcxx
    dotnet-sdk_10
    python3

    pcmanfm

    unityhub
    stremio-linux-shell

    maven
  ];


  programs.java.enable = true;
  programs.chromium.enable = true;
  programs.firefox.enable = true;
  programs.bash.enable = true;
  programs.direnv.enable = true;
  programs.onlyoffice.enable = true;
  programs.dbeaver.enable = true;
  

  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      user.name = "VictorHazebrouck";
      user.email = "hazebrouck.victor@gmail.com";
      core.editor = "zeditor --wait";
      safe.directory = "/etc/nixos";
    };
    lfs.enable = true;
  };


  programs.zed-editor = {
    enable = true;
    userSettings.load_direnv = "direct";
    extraPackages = with pkgs; [ nil nixd omnisharp-roslyn csharp-ls ];
  };


  programs.alacritty = {
    enable = true;
    theme = "gruvbox_dark";
    settings.window.opacity = 0.97;
  };


  programs.rofi = {
    enable = true;
    terminal = "alacritty";
    modes = [ "drun" "emoji" "run" "ssh" ];
    extraConfig = { display-drun = "app"; display-run = "cmd"; hide-scrollbar = true; };
    plugins = [ pkgs.rofi-emoji ];
    theme = builtins.toFile "rofi-theme.rasi" ''
      * { bg: #32302fdd; fg: #d4be98; hover: #665c5499; }
      * { background-color: transparent; font-family: "JetBrains Mono"; text-color: @fg; }
      window { transparency: "real"; background-color: @bg; width: 35%; height: 500px; }
      prompt, entry, textbox, button, element-text { padding: 7px; }
      element.selected { background-color: @hover; }
    '';
  };


  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    swaynag.enable = true;
    extraOptions = [ "--unsupported-gpu" ];
    config = {
      bars = [{ command = "swaybar_command_waybar"; }];
      modifier = "Mod4";
      terminal = "alacritty";
      menu = "rofi -show drun";
      input."type:keyboard" = {
        xkb_options = "compose:rwin,numpad:mac";
      };
      input."type:touchpad" = {
        tap = "enabled";
        dwt = "enabled";
        drag = "enabled";
        drag_lock = "enabled";
      };
      output."*" = { scale = "1.25"; bg = "${./Wallpapers/Wallpaper2.png} fill"; };
      defaultWorkspace = "1";
      gaps = { inner = 7; smartGaps = true; smartBorders = "on"; };
      window = { titlebar = false; };
      assigns = {
        "4" = [{ app_id = "firefox"; }];
        "3" = [{ app_id = "chromium"; }];
      };
      bindswitches = {
        #"lid:on" =  { locked = true; action = "output eDP-1 disable"; };
        #"lid:off" = { locked = true; action = "output eDP-1 enable"; };
      };
      keybindings = lib.mkOptionDefault {
        "Mod4+c" = "exec ${pkgs.cliphist}/bin/cliphist list | rofi -dmenu | cliphist decode | ${pkgs.wl-clipboard}/bin/wl-copy";
        "Mod4+p" = "exec ${pkgs.wl-color-picker}/bin/wl-color-picker";
        "Print" = "exec ${pkgs.grim}/bin/grim ~/Pictures/screenshot-$(date +%F-%T).png";
        "Shift+Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" ~/Pictures/screenshot-$(date +%F-%T).png";
        "Ctrl+Shift+Print" = "exec ${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy";
        "XF86AudioRaiseVolume" = "exec ${pkgs.swayosd}/bin/swayosd-client --output-volume raise";
        "XF86AudioLowerVolume" = "exec ${pkgs.swayosd}/bin/swayosd-client --output-volume lower";
        "XF86AudioMute" = "exec ${pkgs.swayosd}/bin/swayosd-client --output-volume mute-toggle";
        "XF86AudioMicMute" = "exec ${pkgs.swayosd}/bin/swayosd-client --input-volume mute-toggle";
        "XF86MonBrightnessUp" = "exec ${pkgs.swayosd}/bin/swayosd-client --brightness raise";
        "XF86MonBrightnessDown" = "exec ${pkgs.swayosd}/bin/swayosd-client --brightness lower";
        "XF86AudioPlay" = "exec ${pkgs.swayosd}/bin/swayosd-client --playerctl play-pause";
        "XF86AudioNext" = "exec ${pkgs.swayosd}/bin/swayosd-client --playerctl next";
      };
    };
  };
  services.swayosd.enable = true;
  services.cliphist.enable = true;


  programs.waybar = {
    enable = true;
    systemd.enable = true;
    systemd.targets = [ "graphical-session.target" ];
    settings = [
      {
        layer = "top";
        position = "bottom";
        height = 20;
        modules-left = [ "sway/workspaces" ];
        "sway/workspaces" = { all-outputs = true; disable-scroll = true; };
        modules-right = [ "pulseaudio" "cpu" "memory" "battery" "network" "clock" ];
        pulseaudio = {
          format = "{format_source} 󰕾 {volume}%";
          format-muted = "{format_source} 󰖁 0%";
          format-source = "";
          format-source-muted = "󰍭";
          on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          on-click-right = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";
          on-scroll-up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +1%";
          on-scroll-down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -1%";
          tooltip = false;
        };
        battery = {
          interval = 5;
          format = "{icon} {capacity}%";
          format-icons = [ "" "" "" "" "" ];
          format-charging = " {capacity}%";
          format-plugged = " {capacity}%";
          format-full = " {capacity}%";
          tooltip-format = "{timeTo}\n{capacity}% {power}W";
        };
        cpu = {
          interval = 5;
          tooltip = false;
          format = " {usage}%";
          format-alt = " {load}";
        };
        memory = {
          interval = 5;
          format = " {used}G";
          format-alt = " {percentage}%";
          tooltip = false;
        };
        network = {
          icon-size = 20;
          interval = 5;
          format-wifi = "󰤥 {signalStrength}%";
          format-ethernet = "󰈁";
          format-disconnected = "⚠";
          tooltip-format-wifi = "{essid} {signalStrength}%\nup:{bandwidthUpBytes} down:{bandwidthDownBytes}";
          tooltip-format-ethernet = "{ifname}\nup:{bandwidthUpBytes} down:{bandwidthDownBytes}";
          tooltip-format-disconnected = "Disconnected";
          on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
        };
        clock = {
          format = "{:%d/%m/%y %R}";
          tooltip = false;
        };
      }
    ];
    style = ''
      * {
        background-color: #32302f;
        color: #d4be98;
        font-family: Mononoki Nerd Font;
        font-weight: 600;
        font-size: 13px;
        border: none;
        border-radius: 0;
      }
      *:hover { background: inherit; }
      .modules-right * { padding: 0 8px; }
      #workspaces button { padding: 0 3px; }
      #workspaces button.focused, #workspaces button.active {
        color: white;
        border-bottom: 2px solid #d4be98;
      }
    '';
  };

#  xdg.portal.enable = true;
  home = {
    sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
    };
    username = "victor";
    homeDirectory = "/home/victor";
    stateVersion = "26.05";
  };
}

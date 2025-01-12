
# special thanks to: https://github.com/lostMia/nixos-config
# TODOs
# - monitor scaling
# - fix copying
# - flameshot
# - rofi config
# - rofi show ssh as well
# - fix audio next,prev
# - backgroudn and transperency
# - hibernation
# - swapfile not found in stage1
# - win + D command
# - kernel output for luks pwd on all displays

{ pkgs, nur, unstable, ... }: {

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        #command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time -d --env WLR_RENDERER_ALLOW_SOFTWARE=1 --cmd sway";
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd ${pkgs.writeScriptBin "run-sway" ''
          export WLR_RENDERER_ALLOW_SOFTWARE=1
          export SDL_VIDEODRIVER=wayland
          export _JAVA_AWT_WM_NONREPARENTING=1
          export QT_QPA_PLATFORM=wayland
          export XDG_CURRENT_DESKTOP=sway
          export XDG_SESSION_DESKTOP=sway
          exec sway
        ''}/bin/run-sway";
        user = "me";
      };
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    audio.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
  xdg.portal = {
    enable = true;
    config = {
      common = {
        default = "wlr";
      };
    };
    wlr.enable = true;
    wlr.settings.screencast = {
      output_name = "eDP-1";
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
    };
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override {fonts = ["Hack"];})
  ];

	sound.enable = true;
  services.blueman.enable = true;
	hardware.bluetooth.enable = true;

  services.keyd = {
    enable = true;
    keyboards.default.settings = {
      main = {
        leftalt = "leftcontrol";
        leftcontrol = "leftalt";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    xdg-desktop-portal
    wlr-randr
    rofi-wayland
    wev
    swayfx
    wl-clipboard
    zoxide
    waybar
    power-profiles-daemon
    brightnessctl
    autotiling
    alejandra
    vesktop
    wayland
    xdg-utils
    grim
    slurp
    unstable.shikane
    networkmanagerapplet
    blueman
    sway-audio-idle-inhibit
    dunst
    libnotify
    nur.repos.kira-bruneau.swaylock-fprintd
    swayidle
    corrupter
    swayosd
    stress
    wl-mirror
    fortune
  ];

  home-manager.users.me.home.file = {
    ".config/sway/config".text = ''

      # c2vi's sway config, stolen from Mia's sway config

      ### Colors
          set $rosewater #f5e0dc
          set $flamingo  #f2cdcd
          set $pink      #f5c2e7
          set $mauve     #cba6f7
          set $red       #f38ba8
          set $maroon    #eba0ac
          set $peach     #fab387
          set $green     #a6e3a1
          set $teal      #94e2d5
          set $sky       #89dceb
          set $sapphire  #74c7ec
          set $blue      #89b4fa
          set $lavender  #b4befe
          set $text      #cdd6f4
          set $subtext1  #bac2de
          set $subtext0  #a6adc8
          set $overlay2  #9399b2
          set $overlay1  #7f849c
          set $overlay0  #6c7086
          set $surface2  #585b70
          set $surface1  #45475a
          set $surface0  #313244
          set $base      #1e1e2e
          set $mantle    #181825
          set $crust     #11111b

      ### Flameshot fix
          exec_always "export SDL_VIDEODRIVER=wayland"
          exec_always "export _JAVA_AWT_WM_NONREPARENTING=1"
          exec_always "export QT_QPA_PLATFORM=wayland"
          exec_always "export XDG_CURRENT_DESKTOP=sway"
          exec_always "export XDG_SESSION_DESKTOP=sway"
          exec_always "export QT_AUTO_SCREEN_SCALE_FACTOR=0"

          exec_always systemctl --user import-environment DISPLAY WAYLAND_DISPLAY SWAYSOCK
          exec_always hash dbus-update-activation-environment 2>/dev/null && \
              dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

      ### Variables
          set $mod Mod1
          set $left h
          set $down j
          set $up k
          set $right l
          set $term alacritty
          set $menu rofi

      ### Font
          font HackNerdFont-Regular 16

      ### Output configuration
          #output * scale 1 bg ${./..}/resources/nix.png fill

      ### Input configuration
          input type:keyboard {
              xkb_layout de,de
              repeat_delay 160,160
              repeat_rate 80,80
              xkb_options altwin:swap_lalt_lwin
          }

          # altwin:swap_lalt_lwin swaps the left alt and windows keys, so the win key is on the right and the alt is on the left.
          # ctrl:swap_ralt_rctl swaps the right alt and right control keys, so the control key is on the left and the alt is on the right.
          #xkb_options grp:rctrl_toggle,altwin:swap_lalt_lwin

          input 2362:628:PIXA3854:00_093A:0274_Touchpad {
              pointer_accel 0
              tap enabled
              accel_profile flat
              scroll_method two_finger
              middle_emulation enabled
          }

          input 1133:49291:Logitech_G502_HERO_Gaming_Mouse {
              accel_profile flat
              pointer_accel -0.5
          }

      ### Border colors and looks
          client.focused           #ff4060   #222222 #ff4060 #ff4060  #ff4060
          client.focused_inactive  #222222   #222222 #ff4060 #222222 #222222
          client.unfocused         #222222 #222222 #222222 #222222 #222222
          client.urgent            $peach    $base $peach $overlay0  $peach
          client.placeholder       $overlay0 $base $text  $overlay0  $overlay0
          client.background        $base

      ## Autostart
          exec autotiling                                                           # Automatically tiles in whatever direction is the longest
          exec "/usr/bin/env bash ${./..}/scripts/idlescript"               # Manages suspending and locking
          exec "/usr/bin/env bash ${./..}/scripts/batteryscript.sh"         # Sends battery notifications when necessary
          exec nm-applet                                                            # Networkmanager applet
          exec blueman-applet                                                       # Bluetoothmanager applet
          exec blueman-tray                                                         # Bluetoothmanager tray icon
          exec shikane                                                              # Manages displays and known display setups
          exec sway-audio-idle-inhibit                                              # Prevents sleep when audio is playing
          exec swayosd-server                                                       # OSD server for audio and screen brightness popups
          exec waybar                                                               # Status bar for sway

          assign [class="vesktop"] workspace 1
          assign [class="Signal"] workspace 1
          assign [app_id="firefox"] workspace 2
          assign [app_id="thunderbird"] workspace 10


      ### Key bindings
          bindsym Mod4+Shift+Return exec $term

          bindsym $mod+Shift+Return exec $term
          bindsym $mod+delete exec $term
          bindsym $mod+Shift+c kill
          bindsym $mod+q reload
          bindsym $mod+x exec ${./..}/scripts/lockscript
          bindsym $mod+Shift+s exec "${./..}/scripts/screenshot.sh"

          #bindsym $mod+p exec $menu -show combi -combi-modes "run" -modi combi -monitor "eDP-1" # rofi
          bindsym $mod+p exec $menu -show combi -combi-modes "run" -modi combi
          bindsym $mod+Shift+p exec $menu -show ssh -monitor "eDP-1"

          bindsym $mod+Shift+q exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'

          bindsym $mod+Shift+Control+c exec "swaymsg exit"

          #bindsym $mod+Escape exec 'swaymsg input type:keyboard xkb_switch_layout next'

          # bindsym $mod+odiaeresis exec woomer
          
          #bindsym $mod+a exec woomer
          #bindsym $mod+p exec ${./..}/scripts/toggle_freeze_process.sh

      # Function Keys
          bindsym $mod+Shift+m exec sleep 0.1 && swaymsg output eDP-1 dpms toggle

          bindsym $mod+Shift+y exec swayosd-client --brightness -2
          bindsym $mod+y exec swayosd-client --brightness +2

          #bindsym $mod+m exec swayosd-client --output-volume mute-toggle --max-volume 200

          bindsym $mod+Shift+v exec swayosd-client --output-volume -2 --max-volume 200
          bindsym $mod+v exec swayosd-client --output-volume +2 --max-volume 200

      # Moving around:
          bindsym $mod+$left focus left
          bindsym $mod+$down focus down
          bindsym $mod+$up focus up
          bindsym $mod+$right focus right

          bindsym $mod+Left focus left
          bindsym $mod+Down focus down
          bindsym $mod+Up focus up
          bindsym $mod+Right focus right

          bindsym $mod+Shift+$left move left
          bindsym $mod+Shift+$down move down
          bindsym $mod+Shift+$up move up
          bindsym $mod+Shift+$right move right

          bindsym $mod+Shift+Left move left
          bindsym $mod+Shift+Down move down
          bindsym $mod+Shift+Up move up
          bindsym $mod+Shift+Right move right

          bindsym $mod+u workspace prev
          bindsym $mod+i workspace next

      # Workspaces:
          bindsym $mod+1 workspace number 1
          bindsym $mod+2 workspace number 2
          bindsym $mod+3 workspace number 3
          bindsym $mod+4 workspace number 4
          bindsym $mod+5 workspace number 5
          bindsym $mod+6 workspace number 6
          bindsym $mod+7 workspace number 7
          bindsym $mod+8 workspace number 8
          bindsym $mod+9 workspace number 9
          bindsym $mod+0 workspace number 10

          bindsym $mod+Shift+1 move container to workspace number 1
          bindsym $mod+Shift+2 move container to workspace number 2
          bindsym $mod+Shift+3 move container to workspace number 3
          bindsym $mod+Shift+4 move container to workspace number 4
          bindsym $mod+Shift+5 move container to workspace number 5
          bindsym $mod+Shift+6 move container to workspace number 6
          bindsym $mod+Shift+7 move container to workspace number 7
          bindsym $mod+Shift+8 move container to workspace number 8
          bindsym $mod+Shift+9 move container to workspace number 9
          bindsym $mod+Shift+0 move container to workspace number 10

          # define display output names
          set $disp1 "eDP-1"
          set $disp2 "DP-1"
          
          # default display outputs for workspaces with fallback to disp1
          workspace 1 output $disp2 $disp1
          workspace 2 output $disp2 $disp1
          workspace 3 output $disp2 $disp1
          workspace 4 output $disp2 $disp1
          workspace 5 output $disp2 $disp1
          workspace 6 output $disp2 $disp1
          workspace 7 output $disp2 $disp1
          workspace 8 output $disp2 $disp1
          workspace 9 output $disp2 $disp1
          workspace 10 output $disp2 $disp1

          workspace_auto_back_and_forth false

      # Fx stuff:
          blur disable
          blur_passes 0
          blur_radius 1
          blur_noise 0
          blur_brightness 1

          corner_radius 12
          default_dim_inactive 0.15

      # Layout stuff:
          gaps inner 2
          gaps outer 2

          gaps top 5
          #smart_borders on
          #smart_gaps on

          default_border pixel 2
          corner_radius 0
          # disable_titlebar yes
          floating_modifier $mod normal

          #bindsym $mod+h splith
          #bindsym $mod+m splitv

          # Switch the current container between different layout styles
          bindsym $mod+Comma layout tabbed
          bindsym $mod+Period layout toggle split

          bindsym $mod+Return fullscreen
          bindsym $mod+Shift+space floating toggle
          bindsym $mod+space focus mode_toggle

      # Scratchpad:
          # Sway has a "scratchpad", which is a bag of holding for windows.
          # You can send windows there and get them back later.

          # Move the currently focused window to the scratchpad
          bindsym $mod+Shift+Tab move scratchpad

          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          bindsym $mod+Tab scratchpad show

      # Resizing containers:
          #mode "resize" {
          # left will shrink the containers width
          # right will grow the containers width
          # up will shrink the containers height
          # down will grow the containers height
          set $move_amount 175px

          bindsym $mod+Mod4+$right resize grow width $move_amount
          bindsym $mod+Mod4+$up resize shrink height $move_amount
          bindsym $mod+Mod4+$down resize grow height $move_amount
          bindsym $mod+Mod4+$left resize shrink width $move_amount

          bindsym $mod+Mod4+Left resize grow width $move_amount
          bindsym $mod+Mod4+Down resize shrink height $move_amount
          bindsym $mod+Mod4+Up resize grow height $move_amount
          bindsym $mod+Mod4+Right resize shrink width $move_amount

      # Return to default mode
          # bindsym Return mode "default"
          # bindsym Escape mode "default"
          # bindsym $mod+r mode "resize"
    '';
  };


  home-manager.users.me.programs.waybar = {
    enable = true;
    settings = {
      mainbar = {
        layer = "top";
        position = "top";

        modules-left = [
          "group/options"
          "sway/workspaces"
          "sway/window#protocol"
          "sway/window#name"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "tray"
          "pulseaudio"
          "custom/gpu"
          "memory"
          "cpu"
          "temperature"
          "battery"
          "power-profiles-daemon"
          "custom/power-usage"
          "disk"
        ];

        "custom/separator" = {
          format = " ";
          tooltip = false;
        };
        "custom/options" = {
          format = "   ";
          tooltip = false;
        };

        "idle_inhibitor" = {
          format = " {icon}";
          format-icons = {
            activated = " ";
            deactivated = "󰒲 ";
          };
        };

        "custom/quit" = {
          format = " 󰗼 ";
          tooltip = false;
          on-click = "swaymsg exit";
        };
        "custom/lock" = {
          format = " 󰍁 ";
          tooltip = false;
          on-click = "swaylock";
        };
        "custom/reboot" = {
          format = "  ";
          tooltip = false;
          on-click = "/run/current-system/sw/bin/reboot";
        };
        "custom/power" = {
          format = "  ";
          tooltip = false;
          on-click = "/run/current-system/sw/bin/shutdown now";
        };

        "sway/workspaces" = {
          disable-scroll = true;
          format = "  {name}  ";
        };

        "sway/window#protocol" = {
          format = "{shell}";
          max-length = 50;
          rewrite = {
            xwayland = "<span color='#ffcccc'>   </span>";
            xdg_shell = "<span color='#ccffcc'>   </span>";
            "" = "   ᨐ ";
          };
        };
        "sway/window#name" = {
          format = "{title} ";
          max-length = 25;
          rewrite = {
            "(.*)Mozilla Firefox(.*)" = "󰈹  ";
            "(.*)nvim(.*)" = "  ";
            "(.*)Neovide(.*)" = "  ";
            "(.*)~(.*)" = "  ";
            "(.*)Alacritty(.*)" = "  ";
            "" = "";
          };
        };

        "sway/language" = {
          format = "{variant}";
          tooltip = false;
          on-click = "swaymsg input type:keyboard xkb_switch_layout next";
          rewrite = {
            "(.*)bone(.*)" = "eeeeeeeeeeee ";
            "" = "   ᨐ ";
          };
        };

        "custom/timer" = {
          exec = "${./..}/scripts/waybar-timer.sh updateandprint";
          exec-on-event = true;
          return-type = "json";
          interval = 1;
          signal = 4;
          format = "{icon} {0}";
          format-icons = {
            standby = "󰔞";
            running = "󱎫";
            paused = "󱫟";
          };
          on-click = "${./..}/scripts/waybar-timer.sh new 25 'notify-send \"Timer done!\"'";
          on-click-middle = "${./..}/scripts/waybar-timer.sh cancel";
          on-click-right = "${./..}/scripts/waybar-timer.sh togglepause";
          on-scroll-up = "${./..}/scripts/waybar-timer.sh increase 60 || ${./..}/scripts/waybar-timer.sh new 1 'notify-send -u critical \"Timer expired.\"'";
          on-scroll-down = "${./..}/scripts/waybar-timer.sh increase -60";
        };

        "clock" = {
          format = "   {:%H:%M}";
          format-alt = "{:%A, %B %d, %Y} ";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
          locale = "C";
          calendar = {
            mode = "year";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#f9e2af'><b>{}</b></span>";
              days = "<span color='#ffffff'>{}</span>";
              weeks = "<span color='#e78284'>{}</span>";
              weekdays = "<span color='#eba0ac'>{}</span>";
              today = "<span color='#ff0000'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };

        "custom/outside-temperature" = {
          interval = 1;
          exec = "${./..}/nixos/scripts/get_weather_data.sh";
          tooltip-format = "Innsbruck Temperatur: {}°C";
          format = "T {}°C";
          tooltip = true;
        };

        "tray" = {
          icon-size = 18;
          spacing = 5;
        };

        "pulseaudio" = {
          format = "{icon} {volume:2}%";
          format-bluetooth = " {volume}%";
          format-muted = "󰝟";
          format-icons = {
            headphones = "";
            default = [
              ""
              ""
            ];
          };
          scroll-step = 5;
          on-click = "pamixer -t";
          on-click-right = "pavucontrol";
        };

        "custom/gpu" = {
          interval = 1;
          exec = "cat /sys/class/hwmon/hwmon*/device/gpu_busy_percent";
          format = "󰢮  {}%";
          tooltip = true;
        };

        "memory" = {
          interval = 1;
          format = " {}%";
        };

        "cpu" = {
          interval = 1;
          format = " {usage:2}%";
        };

        "temperature" = {
          interval = 1;
          thermal-zone = 2;
          critical-threshold = 80;
          format = "{icon} {temperatureC}°C";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
            ""
          ];
        };

        "battery" = {
          interval = 1;
          states = {
            good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [
            "󰂎"
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        "disk" = {
          interval = 60;
          format = "󰋊 {percentage_used:2}%";
          path = "/";
        };

        "custom/power-usage" = {
          exec = "${pkgs.bash}/bin/bash ${./..}/scripts/get_power_usage.sh";
          format = "{}W";
          interval = 1;
        };

        "power-profiles-daemon" = {
          format = "{icon}";
          tooltip-format = "Power profile: {profile}";
          tooltip = true;
          format-icons = {
            default = "";
            performance = "";
            balanced = "";
            power-saver = "";
          };
        };

        "user" = {
          format = " {work_d}d {work_H}h";
          interval = 60;
          height = 20;
          width = 20;
        };

        "group/options" = {
          orientation = "horizontal";
          drawer = {
            transition-duration = 300;
            children-class = "option";
            transition-left-to-right = true;
          };
          modules = [
            "custom/options"
            "user"
            "idle_inhibitor"
            "custom/quit"
            "custom/lock"
            "custom/reboot"
            "custom/power"
          ];
        };
      };
    };

    style = ''
      * {
      	font-size: 22px;
        font-family: "HackNerdFont-Regular", monospace;
      }

      window#waybar {
      	background: rgba(0,0,0,0);
      	color: #ffffff;
      }

      #custom-options,
      #custom-quit,
      #custom-lock,
      #custom-reboot,
      #custom-power,
      #idle_inhibitor,
      #user,
      #custom-timer,
      #clock,
      #language,
      #tray,
      #custom-outside-temperature,
      #pulseaudio,
      #custom-gpu,
      #memory,
      #cpu,
      #temperature,
      #battery,
      #power-profiles-daemon,
      #custom-power-usage,
      #disk {
      	background: #1c1c1c;
      	padding: 0px 15px;
      	margin: 0 4px;
      	border-radius: 20px;
      	transition: background-color 0.2s ease;
      	transition: color 0.2s ease;
      }

      #custom-options {
      	border-radius: 20px;
      	padding-right: 5px;
      	color: #b4befe;
      }

      #user:hover,
      #idle_inhibitor:hover,
      #custom-quit:hover,
      #custom-lock:hover,
      #custom-reboot:hover,
      #custom-power:hover,
      #custom-options:hover,
      #user:hover,
      #custom-timer:hover,
      #clock:hover,
      #pulseaudio:hover,
      #custom-gpu:hover,
      #memory:hover,
      #cpu:hover,
      #temperature:hover,
      #battery:hover,
      #power-profiles-daemon:hover,
      #custom-power-usage:hover,
      #disk:hover,
      #custom-outside-temperature:hover {
      	color: #000000;
      }

      #idle_inhibitor,
      #custom-quit,
      #custom-lock,
      #custom-reboot,
      #custom-power {
      	background: #1c1c1c;
      	margin-left: 3px;
      	margin-right: 3px;
      }

      #custom-options {
      	color: #cba6f7;
      	border: 1.5px solid #cba6f7;
      	padding-left: 10px;
      }

      #user {
      	color: #b4befe;
      	border: 1.5px solid #b4befe;
      	padding-right: 20px;
      }

      #idle_inhibitor
      {
      	color: #89dceb;
      	border: 1.5px solid #89dceb;
      	padding-right: 20px;
      }

      #custom-quit {
      	color: #a6e3a1;
      	border: 1.5px solid #a6e3a1;
      	padding-right: 20px;
      }
      #custom-lock {
      	color: #f9e2af;
      	border: 1.5px solid #f9e2af;
      	padding-right: 20px;
      }
      #custom-reboot {
      	color: #fab387;
      	border: 1.5px solid #fab387;
      	padding-right: 20px;
      }
      #custom-power {
      	color: #e78284;
      	border: 1.5px solid #e78284;
      	padding-right: 20px;
      }

      #custom-options:hover {
      	background: #cba6f7;
      }
      #user:hover {
      	background: #b4befe;
      }
      #idle_inhibitor:hover {
      	background: #89dceb;
      }
      #custom-quit:hover {
      	background: #a6e3a1;
      }
      #custom-lock:hover {
      	background: #f9e2af;
      }
      #custom-reboot:hover {
      	background: #fab387;
      }
      #custom-power:hover {
      	background: #e78284;
      }

      #workspaces button {
      	padding: 0px;
      	color: #ffffff;
      	background: #1c1c1c;
      	margin-left: 4px;
      	margin-right: 4px;
      	border-radius: 20px;
      }

      #workspaces button.focused {
      	color: #000000;
      	background: #ffffff;
      }
      #workspaces button:hover {
      	color: #000000;
      	box-shadow: inherit;
      	text-shadow: inherit;
      }
      #workspaces button:nth-child(1) {
      	border: 1.5px solid #b4befe;
      }
      #workspaces button:nth-child(2) {
      	border: 1.5px solid #89dceb;
      }
      #workspaces button:nth-child(3) {
      	border: 1.5px solid #a6e3a1;
      }
      #workspaces button:nth-child(4) {
      	border: 1.5px solid #f9e2af;
      }
      #workspaces button:nth-child(5) {
      	border: 1.5px solid #fab387;
      }
      #workspaces button:nth-child(6) {
      	border: 1.5px solid #e78284;
      }
      #workspaces button:nth-child(7) {
      	border: 1.5px solid #eba0ac;
      }
      #workspaces button:nth-child(8) {
      	border: 1.5px solid #f5c2e7;
      }
      #workspaces button:nth-child(9) {
      	border: 1.5px solid #cba6f7;
      }
      #workspaces button:nth-child(10) {
      	border: 1.5px solid #ffffff;
      }
      #workspaces button.focused:nth-child(1),
      #workspaces button:hover:nth-child(1) {
      	background: #b4befe;
      }
      #workspaces button.focused:nth-child(2),
      #workspaces button:hover:nth-child(2) {
      	background: #89dceb;
      }
      #workspaces button.focused:nth-child(3),
      #workspaces button:hover:nth-child(3) {
      	background: #a6e3a1;
      }
      #workspaces button.focused:nth-child(4),
      #workspaces button:hover:nth-child(4) {
      	background: #f9e2af;
      }
      #workspaces button.focused:nth-child(5),
      #workspaces button:hover:nth-child(5) {
      	background: #fab387;
      }
      #workspaces button.focused:nth-child(6),
      #workspaces button:hover:nth-child(6) {
      	background: #e78284;
      }
      #workspaces button.focused:nth-child(7),
      #workspaces button:hover:nth-child(7) {
      	background: #eba0ac;
      }
      #workspaces button.focused:nth-child(8),
      #workspaces button:hover:nth-child(8) {
      	background: #f5c2e7;
      }
      #workspaces button.focused:nth-child(9),
      #workspaces button:hover:nth-child(9) {
      	background: #cba6f7;
      }
      #workspaces button.focused:nth-child(10),
      #workspaces button:hover:nth-child(10) {
      	background: #ffffff;
      }

      #custom-timer {
      	border: 1.5px solid #f9e2af;
      }

      #window.protocol {
      	background: #1c1c1c;
      	margin-left: 2px;
      	border: 1.5px solid #ffffff;
      	border-right: none;
      	border-radius: 20px 0px 0px 20px;
      }

      #window.name {
      	background: #1c1c1c;
      	border: 1.5px solid #ffffff;
      	border-left: none;
      	border-radius: 0px 20px 20px 0px;
      }

      #clock {
      	padding: 0px 20px 0px 20px;
      	font-family: sourcecodepronormal;
      	border: 1.5px solid #ffffff;
      	color: #ffffff;
      }

      #language {
      	padding: 0px 20px 0px 20px;
      	border: 1.5px solid #ffffff;
      	color: #ffffff;
      }

      tooltip {
      	background-color: #171717;
      	padding: 20px;
      	margin: 20px;
      	border-width: 2px;
      	border-color: #aaaaaa;
      	border-radius: 20px;
      }

      #clock:hover {
      	background: #ffffff;
      }

      #custom-outside-temperature {
      	border: 1.5px solid #cba6f7;
      }

      #custom-outside-temperature:hover {
      	background: #cba6f7;
      }

      #tray {
      	border: 1.5px solid #cba6f7;
      }
      #pulseaudio {
      	border: 1.5px solid #f5c2e7;
      }
      #custom-gpu {
      	border: 1.5px solid #eba0ac;
      }
      #memory {
      	border: 1.5px solid #e78284;
      }
      #cpu {
      	border: 1.5px solid #fab387;
      }
      #temperature {
      	border: 1.5px solid #f9e2af;
      }
      #battery {
      	border: 1.5px solid #a6e3a1;
      }
      #custom-power-usage,
      #power-profiles-daemon {
      	border: 1.5px solid #89dceb;

      }
      #disk {
      	border: 1.5px solid #b4befe;
      }

      #power-profiles-daemon {
      	margin-right: 0px;
      	padding-right: 16px;
      	border-radius: 20px 0px 0px 20px;
      	border-right: none;
      }

      #custom-power-usage {
      	margin-left: 0px;
      	padding-left: 0px;
      	border-radius: 0px 2px;
      	border-radius: 0px 20px 20px 0px;
      	border-left: none;
      }

      #custom-timer:hover {
      	background: #f9e2af;
      }
      #tray:hover {
      	background:  #cba6f7;
      }
      #pulseaudio:hover {
      background: #f5c2e7;
      }
      #custom-gpu:hover {
      background: #eba0ac;
      }
      #memory:hover {
      background: #e78284;
      }
      #cpu:hover {
      background: #fab387;
      }
      #temperature:hover {
      background: #f9e2af;
      }
      #battery:hover {
      background: #a6e3a1;
      }
      #custom-power-usage:hover,
      #power-profiles-daemon:hover {
      background: #89dceb;
      }
      #disk:hover {
      background: #b4befe;
      }
    '';
  };

  home-manager.users.me.home.file.".config/swaylock/config".text = ''
    daemonize
    show-failed-attempts
    show-keyboard-layout
    ignore-empty-password
    fingerprint
    image=$HOME/Pictures/Screenshots/screen.png
    indicator-radius=200
    indicator-thickness=10
    inside-color=#00000000
    line-color=#00000000
    ring-color=#00000000
    text-color=#00000000

    layout-bg-color=#00000000
    layout-text-color=#00000000

    inside-clear-color=#00000000
    line-clear-color=#00000000
    ring-clear-color=#ffff99
    text-clear-color=#00000000

    inside-ver-color=#00000000
    line-ver-color=#00000000
    ring-ver-color=#70ffff
    text-ver-color=#00000000

    inside-wrong-color=#00000000
    line-wrong-color=#00000000
    ring-wrong-color=#ff5555
    text-wrong-color=#00000000

    bs-hl-color=#ff5555
    key-hl-color=#99ff99

    text-caps-lock-color=#ffffff
  '';

}

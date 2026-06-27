{ ... }:

{
  home.file.".config/zellij/config.kdl".text = ''
    default_shell "fish"
    default_layout "compact"

    pane_frames false
    simplified_ui true

    copy_command "pbcopy"
    copy_clipboard "system"

    theme "melqtx"

    themes {
      melqtx {
        fg 205 214 244
        bg 30 30 46
        black 69 71 90
        red 243 139 168
        green 166 227 161
        yellow 249 226 175
        blue 137 180 250
        magenta 203 166 247
        cyan 137 220 235
        white 205 214 244
        orange 250 179 135
      }
    }

    keybinds {
      normal {
        bind "Ctrl q" { Quit; }
        bind "Ctrl d" { Detach; }
      }

      session {
        bind "q" { Quit; }
        bind "d" { Detach; }
        bind "Esc" { SwitchToMode "Normal"; }
      }
    }
  '';
}

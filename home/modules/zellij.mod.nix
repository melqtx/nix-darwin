{ ... }:

{
  flake.homeModules.zellij = {
    xdg.configFile."zellij/config.kdl".text = /* kdl */ ''
      default_shell "fish"
      default_layout "battlestation"

      pane_frames false
      simplified_ui false

      copy_command "pbcopy"
      copy_clipboard "system"

      theme "melqtx-muted"

      themes {
        melqtx-muted {
          fg 213 196 161
          bg 40 40 40
          black 40 40 40
          red 234 105 98
          green 184 187 38
          yellow 215 153 33
          blue 125 174 163
          magenta 211 134 155
          cyan 137 180 130
          white 213 196 161
          orange 230 126 34
        }
      }

      keybinds {
        shared_except "locked" {
          bind "Ctrl h" { MoveFocus "Left"; }
          bind "Ctrl j" { MoveFocus "Down"; }
          bind "Ctrl k" { MoveFocus "Up"; }
          bind "Ctrl l" { MoveFocus "Right"; }

          bind "Super h" { GoToPreviousTab; }
          bind "Super l" { GoToNextTab; }
          bind "Super t" { NewTab; }
          bind "Super w" { CloseTab; }

          bind "Ctrl Shift h" { MovePane "Left"; }
          bind "Ctrl Shift j" { MovePane "Down"; }
          bind "Ctrl Shift k" { MovePane "Up"; }
          bind "Ctrl Shift l" { MovePane "Right"; }

          bind "Alt h" { NewPane "Left"; }
          bind "Alt j" { NewPane "Down"; }
          bind "Alt k" { NewPane "Up"; }
          bind "Alt l" { NewPane "Right"; }

          bind "Alt Shift h" { Resize "Increase Left"; }
          bind "Alt Shift j" { Resize "Increase Down"; }
          bind "Alt Shift k" { Resize "Increase Up"; }
          bind "Alt Shift l" { Resize "Increase Right"; }

          bind "Ctrl f" { ToggleFocusFullscreen; }
          bind "Ctrl p" { NewPane; ToggleFloatingPanes; }
          bind "Ctrl q" { Quit; }
          bind "Ctrl d" { Detach; }
        }
      }
    '';

    xdg.configFile."zellij/layouts/battlestation.kdl".text = /* kdl */ ''
      layout {
        tab name="battlestation" focus=true hide_floating_panes=true {
          pane split_direction="vertical" {
            pane size="30%" {
              pane cwd="dev" size="50%"
              pane cwd="dev" size="50%"
            }
            pane command="zellij" cwd="dev" focus=true size="45%" {
              args "action" "dump-layout"
              start_suspended true
            }
            pane size="25%" {
              pane cwd="dev" size="50%"
              pane cwd="dev" size="50%"
            }
          }
        }
      }
    '';
  };
}

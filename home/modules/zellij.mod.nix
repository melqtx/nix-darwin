{ ... }:

{
  flake.homeModules.zellij = { config, ... }: {
    xdg.configFile."zellij/config.kdl".text = /* kdl */ ''
      default_shell "fish"
      default_layout "clean"

      pane_frames false
      simplified_ui true
      session_serialization false

      copy_command "pbcopy"
      copy_clipboard "system"

      theme "catppuccin-mocha"

      themes {
        catppuccin-mocha {
          fg 205 214 244
          bg 30 30 46
          black 49 50 68
          red 243 139 168
          green 166 227 161
          yellow 249 226 175
          blue 137 180 250
          magenta 203 166 247
          cyan 148 226 213
          white 186 194 222
          orange 250 179 135
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

    xdg.configFile."zellij/layouts/clean.kdl".text = /* kdl */ ''
      layout {
        pane
        pane size=1 borderless=true {
          plugin location="tab-bar"
        }
      }
    '';

    xdg.configFile."zellij/layouts/battlestation.kdl".text = /* kdl */ ''
      layout {
        tab name="battlestation" focus=true hide_floating_panes=true {
          pane split_direction="vertical" {
            pane size="30%" {
              pane cwd="${config.home.homeDirectory}/code" size="50%"
              pane cwd="${config.home.homeDirectory}/code" size="50%"
            }
            pane command="zellij" cwd="${config.home.homeDirectory}/code" focus=true size="45%" {
              args "action" "dump-layout"
              start_suspended true
            }
            pane size="25%" {
              pane cwd="${config.home.homeDirectory}/code" size="50%"
              pane cwd="${config.home.homeDirectory}/code" size="50%"
            }
          }
        }
      }
    '';
  };
}

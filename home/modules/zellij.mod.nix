{ ... }:

{
  flake.homeModules.zellij =
    { config, lib, pkgs, ... }:
    let
      inherit (lib.meta) getExe;

      fish = getExe pkgs.fish;
    in
    {
      xdg.configFile."zellij/config.kdl".text = /* kdl */ ''
      default_shell "${fish}"
      default_layout "clean"

      pane_frames false
      simplified_ui true
      mouse_mode false
      session_serialization false
      show_release_notes false
      stacked_resize true

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
          bind "Super r" { SwitchToMode "RenameTab"; TabNameInput 0; }

          bind "Super Shift h" { GoToPreviousTab; }
          bind "Super Shift l" { GoToNextTab; }
          bind "Super Shift t" { NewTab; }
          bind "Super Shift w" { CloseTab; }

          bind "Ctrl Shift h" { MovePane "Left"; }
          bind "Ctrl Shift j" { MovePane "Down"; }
          bind "Ctrl Shift k" { MovePane "Up"; }
          bind "Ctrl Shift l" { MovePane "Right"; }
          bind "Ctrl Shift w" { CloseFocus; }

          bind "Alt h" { NewPane "Left"; }
          bind "Alt j" { NewPane "Down"; }
          bind "Alt k" { NewPane "Up"; }
          bind "Alt l" { NewPane "Right"; }
          bind "Alt v" { NewPane "Right"; }
          bind "Alt s" { NewPane "Down"; }
          bind "Alt Shift s" { NewPane "stacked"; }

          bind "Ctrl Alt h" { Resize "Increase Left"; }
          bind "Ctrl Alt j" { Resize "Increase Down"; }
          bind "Ctrl Alt k" { Resize "Increase Up"; }
          bind "Ctrl Alt l" { Resize "Increase Right"; }
          bind "Ctrl Alt Shift h" { Resize "Decrease Left"; }
          bind "Ctrl Alt Shift j" { Resize "Decrease Down"; }
          bind "Ctrl Alt Shift k" { Resize "Decrease Up"; }
          bind "Ctrl Alt Shift l" { Resize "Decrease Right"; }

          bind "Ctrl f" { ToggleFocusFullscreen; }
          bind "Ctrl p" { NewPane; TogglePaneEmbedOrFloating; }
          bind "Ctrl Shift p" { ToggleFloatingPanes; }
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
          pane size=1 borderless=true {
            plugin location="tab-bar"
          }
        }
      }
    '';
    };
}

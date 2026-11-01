{ config, self, ... }:

let
  inherit (config) theme;
in
{
  perSystem = { pkgs, ... }: {
    packages.zjstatus = pkgs.fetchurl {
      name = "zjstatus-0.25.0.wasm";
      url = "https://github.com/dj95/zjstatus/releases/download/v0.25.0/zjstatus.wasm";
      hash = "sha256-KCzqshnlbhkIyfrDOQckH+bD4e99hfqrPl9DjO+HuP4=";
    };
  };

  flake.homeModules.zellij =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.lists) singleton;
      inherit (lib.meta) getExe;

      fish = getExe config.programs.fish.package;
      zjstatus = self.packages.${pkgs.stdenv.hostPlatform.system}.zjstatus;
      statusPane = ''
        pane size=1 borderless=true {
          plugin location="workspace-status"
        }
      '';
    in
    {
      home.packages = singleton pkgs.zellij;

      xdg.configFile."zellij/config.kdl".text = /* kdl */ ''
        default_shell "${fish}"
        default_layout "clean"
        on_force_close "detach"

        // Shared separators, without boxes around each pane.
        pane_frames false
        auto_layout false
        simplified_ui true
        mouse_mode false
        session_serialization false
        show_release_notes false
        stacked_resize false

        copy_command "pbcopy"
        copy_clipboard "system"

        theme "workspace"

        themes {
          workspace {
            fg "${theme.palette.terminalForeground}"
            bg "${theme.palette.terminalBackground}"
            black "${theme.palette.terminalSurface}"
            red "${theme.palette.red}"
            green "${theme.palette.terminalAccent}"
            yellow "${theme.palette.yellow}"
            blue "${theme.palette.blue}"
            magenta "${theme.palette.magenta}"
            cyan "${theme.palette.cyan}"
            white "${theme.palette.terminalMuted}"
            orange "${theme.palette.terminalAccent}"
          }
        }

        plugins {
          workspace-status location="file:${zjstatus}" {
            color_bg "${theme.palette.terminalBackground}"
            color_surface "${theme.palette.terminalSurface}"
            color_fg "${theme.palette.terminalForeground}"
            color_muted "${theme.palette.terminalMuted}"
            color_accent "${theme.palette.terminalAccent}"

            // Explicitly keep frame management in Zellij, including on resize.
            hide_frame_for_single_pane "false"
            hide_frame_except_for_search "false"
            hide_frame_except_for_fullscreen "false"
            hide_frame_except_for_scroll "false"
            border_enabled "false"

            format_left "{mode} #[fg=$fg,bg=$surface,bold] {session} "
            format_center "{tabs}"
            format_right "{swap_layout}"
            format_space "#[bg=$bg]"
            format_hide_on_overlength "true"
            format_precedence "clr"

            mode_normal "#[fg=$accent,bg=$surface,bold] NORMAL "
            mode_locked "#[fg=$muted,bg=$surface] LOCKED "
            mode_default_to_mode "normal"
            mode_resize "#[fg=$accent,bg=$surface,bold] RESIZE "
            mode_pane "#[fg=$accent,bg=$surface,bold] PANE "
            mode_tab "#[fg=$accent,bg=$surface,bold] TAB "
            mode_scroll "#[fg=$accent,bg=$surface,bold] SCROLL "
            mode_session "#[fg=$accent,bg=$surface,bold] SESSION "
            mode_move "#[fg=$accent,bg=$surface,bold] MOVE "
            mode_search "#[fg=$accent,bg=$surface,bold] SEARCH "
            mode_enter_search "#[fg=$accent,bg=$surface,bold] SEARCH "
            mode_rename_tab "#[fg=$accent,bg=$surface,bold] RENAME "
            mode_rename_pane "#[fg=$accent,bg=$surface,bold] RENAME "

            tab_normal "#[fg=$muted,bg=$bg] {name}{fullscreen_indicator}{sync_indicator}{floating_indicator} "
            tab_active "#[fg=$accent,bg=$surface,bold] {name} #{index}{fullscreen_indicator}{sync_indicator}{floating_indicator} "
            tab_fullscreen_indicator " [FULL]"
            tab_sync_indicator " [SYNC]"
            tab_floating_indicator " [FLOAT]"
            tab_separator " "
            tab_display_count "5"
            tab_truncate_start_format "#[fg=$muted,bg=$bg] ‹ "
            tab_truncate_end_format "#[fg=$muted,bg=$bg] › "

            swap_layout_format "#[fg=$muted,bg=$bg] {name} "
            swap_layout_hide_if_empty "true"
          }
        }

        keybinds {
          normal {
            // History and file search belong to Atuin and fzf in the shell.
            unbind "Ctrl r" "Ctrl t";
          }

          shared_except "locked" {
            bind "Ctrl h" { MoveFocus "Left"; }
            bind "Ctrl j" { MoveFocus "Down"; }
            bind "Ctrl k" { MoveFocus "Up"; }
            bind "Ctrl l" { MoveFocus "Right"; }

            bind "Super h" { GoToPreviousTab; }
            bind "Super l" { GoToNextTab; }
            bind "Super t" { NewTab; SwitchToMode "RenameTab"; TabNameInput 0; }
            bind "Super w" { CloseTab; }
            bind "Super r" { SwitchToMode "RenameTab"; TabNameInput 0; }

            bind "Super Shift h" { GoToPreviousTab; }
            bind "Super Shift l" { GoToNextTab; }
            bind "Super Shift t" { NewTab; SwitchToMode "RenameTab"; TabNameInput 0; }
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
          default_tab_template {
            children
            ${statusPane}
          }

          tab name="main" focus=true {
            pane
          }
          tab name="dots" {
            pane cwd="${config.home.homeDirectory}/dots"
          }
          tab name="work" {
            pane cwd="${config.home.homeDirectory}/Documents/code"
          }
          tab name="scratch" {
            pane
          }
        }
      '';

      xdg.configFile."zellij/layouts/battlestation.kdl".text = /* kdl */ ''
        layout {
          tab name="battlestation" focus=true hide_floating_panes=true {
            pane split_direction="vertical" {
              pane size="30%" {
                pane cwd="${config.home.homeDirectory}/Documents/code" size="50%"
                pane cwd="${config.home.homeDirectory}/Documents/code" size="50%"
              }
              pane command="zellij" cwd="${config.home.homeDirectory}/Documents/code" focus=true size="45%" {
                args "action" "dump-layout"
                start_suspended true
              }
              pane size="25%" {
                pane cwd="${config.home.homeDirectory}/Documents/code" size="50%"
                pane cwd="${config.home.homeDirectory}/Documents/code" size="50%"
              }
            }
            ${statusPane}
          }
        }
      '';
    };
}

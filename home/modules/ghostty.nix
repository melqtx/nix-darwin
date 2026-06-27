{ ... }:

{
  home.file.".config/ghostty/config".text = ''
    font-family = Berkeley Mono
    font-size = 15

    background = 1e1e2e
    foreground = cdd6f4
    cursor-color = f5e0dc
    selection-background = 585b70
    selection-foreground = cdd6f4

    shell-integration = fish

    window-padding-x = 8
    window-padding-y = 8

    background-opacity = 0.95
    background-blur-radius = 20

    cursor-style = block
    cursor-style-blink = false

    confirm-close-surface = false

    copy-on-select = clipboard
    macos-option-as-alt = true

    window-save-state = always
    window-inherit-working-directory = true

    mouse-hide-while-typing = true
  '';
}

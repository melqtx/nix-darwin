{ ... }:

{
  flake.homeModules.helix =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib.meta) getExe;

      bundleIdentifier = "dev.helix-editor.Helix";

      helixLauncher = pkgs.writeShellScript "helix-macos-launcher" ''
        exec /usr/bin/open -na /Applications/Ghostty.app --args \
          -e ${getExe pkgs.helix} "$@"
      '';

      helixInfoPlist = pkgs.writeText "helix-info.plist" ''
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "https://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
          <key>CFBundleDevelopmentRegion</key>
          <string>en</string>
          <key>CFBundleDisplayName</key>
          <string>Helix</string>
          <key>CFBundleDocumentTypes</key>
          <array>
            <dict>
              <key>CFBundleTypeName</key>
              <string>Text document</string>
              <key>CFBundleTypeRole</key>
              <string>Editor</string>
              <key>LSHandlerRank</key>
              <string>Owner</string>
              <key>LSItemContentTypes</key>
              <array>
                <string>public.text</string>
                <string>public.plain-text</string>
                <string>public.source-code</string>
                <string>public.shell-script</string>
                <string>org.nixos.nix-source</string>
              </array>
            </dict>
          </array>
          <key>CFBundleExecutable</key>
          <string>Helix</string>
          <key>CFBundleIdentifier</key>
          <string>${bundleIdentifier}</string>
          <key>CFBundleInfoDictionaryVersion</key>
          <string>6.0</string>
          <key>CFBundleName</key>
          <string>Helix</string>
          <key>CFBundlePackageType</key>
          <string>APPL</string>
          <key>CFBundleShortVersionString</key>
          <string>${pkgs.helix.version}</string>
          <key>CFBundleVersion</key>
          <string>${pkgs.helix.version}</string>
          <key>LSUIElement</key>
          <true/>
          <key>NSHighResolutionCapable</key>
          <true/>
          <key>UTExportedTypeDeclarations</key>
          <array>
            <dict>
              <key>UTTypeConformsTo</key>
              <array>
                <string>public.source-code</string>
              </array>
              <key>UTTypeDescription</key>
              <string>Nix source</string>
              <key>UTTypeIdentifier</key>
              <string>org.nixos.nix-source</string>
              <key>UTTypeTagSpecification</key>
              <dict>
                <key>public.filename-extension</key>
                <array>
                  <string>nix</string>
                </array>
              </dict>
            </dict>
          </array>
        </dict>
        </plist>
      '';

      helixApp = pkgs.runCommandLocal "helix-macos-app" { } ''
        app="$out/Applications/Helix.app/Contents"
        mkdir -p "$app/MacOS"
        install -m 755 ${helixLauncher} "$app/MacOS/Helix"
        install -m 644 ${helixInfoPlist} "$app/Info.plist"
      '';

      githubPermalink = pkgs.callPackage (
        {
          coreutils,
          gnused,
          jujutsu,
          writeShellApplication,
        }:
        writeShellApplication {
          name = "hx-github-permalink";
          runtimeInputs = [
            coreutils
            gnused
            jujutsu
          ];
          text = /* bash */ ''
            file="''${1:?missing file}"
            line="''${2:-1}"

            root="$(jj root 2>/dev/null)"
            remote="$(jj git remote list 2>/dev/null | sed --quiet 's/^origin[[:space:]]*//p' | sed --quiet '1p')"
            change="$(jj log --no-graph --revisions @ --template 'commit_id.short()' 2>/dev/null)"

            relative="''${file#"$root"/}"
            remote="''${remote%.git}"
            remote="''${remote#git@github.com:}"
            remote="''${remote#ssh://git@github.com/}"
            remote="''${remote#https://github.com/}"

            printf 'https://github.com/%s/blob/%s/%s#L%s' "$remote" "$change" "$relative" "$line"
          '';
        }
      ) { };
    in
    {
      home.packages = [
        helixApp
        pkgs.helix
      ];

      home.activation.setHelixAsDefaultEditor = lib.hm.dag.entryAfter [ "copyApps" ] ''
        app="${config.home.homeDirectory}/Applications/Home Manager Apps/Helix.app"
        lsregister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

        $DRY_RUN_CMD "$lsregister" -f "$app"

        for contentType in \
          public.text \
          public.plain-text \
          public.source-code \
          public.shell-script \
          public.json \
          public.yaml \
          public.xml \
          net.daringfireball.markdown \
          org.nixos.nix-source
        do
          $DRY_RUN_CMD ${getExe pkgs.duti} -s ${bundleIdentifier} "$contentType" all
        done
      '';

      xdg.configFile."helix/config.toml".text = /* toml */ ''
        theme = "catppuccin_mocha"

        [editor]
        auto-completion = true
        bufferline = "multiple"
        completion-trigger-len = 2
        line-number = "absolute"
        mouse = false

        [editor.auto-save]
        focus-lost = true

        [editor.cursor-shape]
        insert = "bar"
        normal = "block"
        select = "underline"

        [editor.file-picker]
        hidden = false

        [editor.inline-diagnostics]
        cursor-line = "warning"
        other-lines = "error"

        [editor.lsp]
        display-inlay-hints = true

        [editor.soft-wrap]
        enable = true

        [editor.statusline]
        center = ["file-name"]
        left = ["mode", "spinner"]
        right = [
          "diagnostics",
          "selections",
          "position",
          "file-encoding",
          "file-line-ending",
          "file-type",
        ]
        separator = "│"

        [editor.statusline.mode]
        insert = "INSERT"
        normal = "NORMAL"
        select = "SELECT"

        [keys.insert]
        esc = ["collapse_selection", "normal_mode"]

        [keys.normal]
        w = ["move_next_word_start", "collapse_selection"]
        e = ["move_next_word_end", "collapse_selection"]
        b = ["move_prev_word_start", "collapse_selection"]
        h = ["move_char_left", "collapse_selection"]
        j = ["move_visual_line_down", "collapse_selection"]
        k = ["move_visual_line_up", "collapse_selection"]
        l = ["move_char_right", "collapse_selection"]

        [keys.normal.space.y]
        p = [":sh printf '%s' %{buffer_name} | /usr/bin/pbcopy"]
        g = [":sh ${getExe githubPermalink} %{buffer_name} %{cursor_line} | /usr/bin/pbcopy"]
      '';

      xdg.configFile."helix/languages.toml".text = /* toml */ ''
        [language-server.nixd]
        command = "nixd"

        [language-server.gopls.config]
        staticcheck = true

        [language-server.rust-analyzer.config.check]
        command = "clippy"

        [language-server.ty]
        command = "ty"
        args = ["server"]

        [[language]]
        name = "nix"
        auto-format = true
        formatter = { command = "nixfmt" }
        language-servers = ["nixd"]

        [[language]]
        name = "rust"
        auto-format = true
        formatter = { command = "rustfmt" }
        language-servers = ["rust-analyzer"]
        debugger = { name = "lldb-dap", transport = "stdio", command = "lldb-dap", templates = [{ name = "binary", request = "launch", completion = [{ name = "binary", completion = "filename" }], args = { program = "{0}" } }] }

        [[language]]
        name = "go"
        auto-format = true
        formatter = { command = "gofumpt" }
        language-servers = ["gopls"]

        [[language]]
        name = "python"
        auto-format = true
        formatter = { command = "ruff", args = ["format", "-"] }
        language-servers = ["ty"]

        [[language]]
        name = "typescript"
        auto-format = true
        formatter = { command = "prettier", args = ["--parser", "typescript"] }
        language-servers = ["typescript-language-server"]

        [[language]]
        name = "javascript"
        auto-format = true
        formatter = { command = "prettier", args = ["--parser", "babel"] }
        language-servers = ["typescript-language-server"]

        [[language]]
        name = "haskell"
        auto-format = true
        formatter = { command = "fourmolu" }
        language-servers = ["haskell-language-server"]

        [[language]]
        name = "zig"
        auto-format = true
        formatter = { command = "zig", args = ["fmt", "--stdin"] }
        language-servers = ["zls"]

        [[language]]
        name = "java"
        auto-format = true
        formatter = { command = "google-java-format", args = ["-"] }
        language-servers = ["jdtls"]

        [[language]]
        name = "json"
        auto-format = true
        formatter = { command = "prettier", args = ["--parser", "json"] }
        language-servers = ["vscode-json-language-server"]

        [[language]]
        name = "html"
        auto-format = true
        formatter = { command = "prettier", args = ["--parser", "html"] }
        language-servers = ["vscode-html-language-server"]

        [[language]]
        name = "css"
        auto-format = true
        formatter = { command = "prettier", args = ["--parser", "css"] }
        language-servers = ["vscode-css-language-server"]

        [[language]]
        name = "yaml"
        auto-format = true
        formatter = { command = "prettier", args = ["--parser", "yaml"] }
        language-servers = ["yaml-language-server"]
      '';
    };
}

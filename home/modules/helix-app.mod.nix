{ ... }:

{
  perSystem =
    { pkgs, self', ... }:
    {
      packages.helix-darwin-app = pkgs.callPackage (
        {
          helix,
          lib,
          rex-cli,
          runCommandLocal,
          writeShellScript,
          writeText,
        }:
        let
          inherit (lib.meta) getExe;
          bundleIdentifier = "dev.helix-editor.Helix";
          launcher = writeShellScript "helix-darwin-launcher" /* bash */ ''
            /usr/bin/open -b com.superlogical.rex
            # Rex resolves a single active session automatically. With no
            # unambiguous session, create a dedicated editor session instead.
            if ${getExe rex-cli} window ls --json >/dev/null 2>&1; then
              exec ${getExe rex-cli} run --shell=none --label Helix -- ${getExe helix} "$@"
            fi
            exec ${getExe rex-cli} new --window Helix --shell=none -- ${getExe helix} "$@"
          '';
          infoPlist = writeText "helix-info.plist" /* xml */ ''
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
              <string>${helix.version}</string>
              <key>CFBundleVersion</key>
              <string>${helix.version}</string>
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
        in
        runCommandLocal "helix-darwin-app" { } /* bash */ ''
          app="$out/Applications/Helix.app/Contents"
          mkdir --parents "$app/MacOS"
          install --mode=755 ${launcher} "$app/MacOS/Helix"
          install --mode=644 ${infoPlist} "$app/Info.plist"
        ''
      ) { rex-cli = self'.packages.rex-cli; };
    };
}

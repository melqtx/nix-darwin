{ ... }:

{
  flake.homeModules.hammerspoon =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      statsPath = "${config.home.homeDirectory}/.local/state/input-stats.json";
      hammerspoonConfig = pkgs.writeText "hammerspoon-init.lua" /* lua */ ''
        -- Keep the CLI message port available so Home Manager can reload a
        -- changed configuration instead of leaving the old bindings active.
        require("hs.ipc")

        -- Input tracking and window-management shortcuts need Hammerspoon at login.
        hs.autoLaunch(true)

        local statsPath = "${statsPath}"
        local flushEverySeconds = 5

        -- BSD mkdir has no --parents longform, only -p
        local function ensureParent(path)
          local parent = path:match("(.+)/[^/]+$")
          if parent and not hs.fs.attributes(parent) then
            hs.execute("/bin/mkdir -p '" .. parent .. "'")
          end
        end

        local function now()
          return os.date("!%Y-%m-%dT%H:%M:%SZ")
        end

        local function defaultStats()
          return {
            schema_version = 1,
            started_at = now(),
            updated_at = now(),
            totals = {
              key_presses = 0,
              left_clicks = 0,
              right_clicks = 0,
              middle_clicks = 0,
              other_clicks = 0,
              total_clicks = 0,
              scroll_events = 0,
              scroll_vertical = 0,
              scroll_horizontal = 0,
              drag_events = 0,
              drag_distance_px = 0,
              mouse_move_events = 0,
              mouse_distance_px = 0,
            },
          }
        end

        local stats = defaultStats()
        if hs.fs.attributes(statsPath) then
          stats = hs.json.read(statsPath) or stats
        end
        stats.totals = stats.totals or defaultStats().totals

        local dirty = false
        local lastMousePoint = hs.mouse.absolutePosition()
        local lastDragPoint = nil

        local function markDirty()
          dirty = true
          stats.updated_at = now()
        end

        local function flush()
          if not dirty then
            return
          end

          ensureParent(statsPath)
          hs.json.write(stats, statsPath, true, true)
          dirty = false
        end

        dirty = true
        flush()
        inputStatsFlushTimer = hs.timer.doEvery(flushEverySeconds, flush)

        local eventTypes = hs.eventtap.event.types
        inputStatsTap = hs.eventtap.new({
          eventTypes.keyDown,
          eventTypes.leftMouseDown,
          eventTypes.rightMouseDown,
          eventTypes.otherMouseDown,
          eventTypes.scrollWheel,
          eventTypes.leftMouseDragged,
          eventTypes.rightMouseDragged,
          eventTypes.otherMouseDragged,
          eventTypes.mouseMoved,
        }, function(event)
          local eventType = event:getType()
          local totals = stats.totals

          if eventType == eventTypes.keyDown then
            totals.key_presses = totals.key_presses + 1
          elseif eventType == eventTypes.leftMouseDown then
            totals.left_clicks = totals.left_clicks + 1
            totals.total_clicks = totals.total_clicks + 1
            lastDragPoint = hs.mouse.absolutePosition()
          elseif eventType == eventTypes.rightMouseDown then
            totals.right_clicks = totals.right_clicks + 1
            totals.total_clicks = totals.total_clicks + 1
            lastDragPoint = hs.mouse.absolutePosition()
          elseif eventType == eventTypes.otherMouseDown then
            local button = event:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
            if button == 2 then
              totals.middle_clicks = totals.middle_clicks + 1
            else
              totals.other_clicks = totals.other_clicks + 1
            end
            totals.total_clicks = totals.total_clicks + 1
            lastDragPoint = hs.mouse.absolutePosition()
          elseif eventType == eventTypes.scrollWheel then
            totals.scroll_events = totals.scroll_events + 1
            totals.scroll_vertical = totals.scroll_vertical + math.abs(event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1) or 0)
            totals.scroll_horizontal = totals.scroll_horizontal + math.abs(event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis2) or 0)
          elseif eventType == eventTypes.mouseMoved then
            local point = hs.mouse.absolutePosition()
            local dx = point.x - lastMousePoint.x
            local dy = point.y - lastMousePoint.y
            totals.mouse_move_events = totals.mouse_move_events + 1
            totals.mouse_distance_px = totals.mouse_distance_px + math.sqrt(dx * dx + dy * dy)
            lastMousePoint = point
          else
            local point = hs.mouse.absolutePosition()
            local previousPoint = lastDragPoint or point
            local dx = point.x - previousPoint.x
            local dy = point.y - previousPoint.y
            totals.drag_events = totals.drag_events + 1
            totals.drag_distance_px = totals.drag_distance_px + math.sqrt(dx * dx + dy * dy)
            lastDragPoint = point
            lastMousePoint = point
          end

          markDirty()
          return false
        end)

        inputStatsTap:start()
        hs.shutdownCallback = flush

        -- publish stats to melqtx.com: cmd+alt+ctrl+S on demand, plus a
        -- daily auto-publish. Scheduled runs stay silent unless something
        -- actually happened (push or failure).
        local publishStatsScript = "/Users/melqtx/Documents/code/github/1337/bin/update-input-stats"
        local function publishStats(interactive)
          flush()
          if interactive then
            hs.notify.new({ title = "input stats", informativeText = "publishing..." }):send()
          end
          hs.task.new("/bin/zsh", function(exitCode, stdOut, stdErr)
            local text
            if exitCode == 0 then
              text = stdOut:gsub("%s+$", "")
              if not interactive and text:find("no change") then
                return
              end
            else
              text = "failed: " .. stdErr:gsub("%s+$", "")
            end
            hs.notify.new({ title = "input stats", informativeText = text }):send()
          end, { "-lc", publishStatsScript }):start()
        end

        hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "S", function()
          publishStats(true)
        end)

        publishStatsTimer = hs.timer.doAt("21:00", "1d", function()
          publishStats(false)
        end)

        -- Hyper layer disabled after switching to the Sofle v2. Keep the
        -- modal bindings below available in case another trigger is added.
        local hyper = hs.hotkey.modal.new()
        -- hs.hotkey.bind({}, "f18", function()
        --   hyper:enter()
        -- end, function()
        --   hyper:exit()
        -- end)

        local function focusWindow(direction)
          return function()
            local win = hs.window.focusedWindow()
            if win then
              win["focusWindow" .. direction](win, nil, true, true)
            end
          end
        end

        hyper:bind({}, "h", focusWindow("West"))
        hyper:bind({}, "j", focusWindow("South"))
        hyper:bind({}, "k", focusWindow("North"))
        hyper:bind({}, "l", focusWindow("East"))

        -- Modified Hyper chords are deliberately separate from the bare
        -- hjkl focus bindings and from zellij/ghostty's Ctrl and Super keys.
        local function withFocusedWindow(action)
          return function()
            local win = hs.window.focusedWindow()
            if win then
              action(win)
            end
          end
        end

        local function snapWindow(position)
          return withFocusedWindow(function(win)
            win:move(position, nil, true, 0)
          end)
        end

        -- hs.layout has no top50/bottom50 equivalents, only left/right
        hyper:bind({ "shift" }, "h", snapWindow(hs.layout.left50))
        hyper:bind({ "shift" }, "j", snapWindow(hs.geometry.rect(0, 0.5, 1, 0.5)))
        hyper:bind({ "shift" }, "k", snapWindow(hs.geometry.rect(0, 0, 1, 0.5)))
        hyper:bind({ "shift" }, "l", snapWindow(hs.layout.right50))

        local function resizeWindow(widthDelta, heightDelta)
          return withFocusedWindow(function(win)
            local frame = win:frame()
            local screenFrame = win:screen():frame()
            local widthStep = math.floor(screenFrame.w * 0.05)
            local heightStep = math.floor(screenFrame.h * 0.05)
            local maxWidth = screenFrame.x + screenFrame.w - frame.x
            local maxHeight = screenFrame.y + screenFrame.h - frame.y

            frame.w = math.max(320, math.min(maxWidth, frame.w + widthDelta * widthStep))
            frame.h = math.max(240, math.min(maxHeight, frame.h + heightDelta * heightStep))
            win:setFrame(frame, 0)
          end)
        end

        hyper:bind({ "ctrl" }, "h", resizeWindow(-1, 0))
        hyper:bind({ "ctrl" }, "j", resizeWindow(0, 1))
        hyper:bind({ "ctrl" }, "k", resizeWindow(0, -1))
        hyper:bind({ "ctrl" }, "l", resizeWindow(1, 0))

        hyper:bind({}, "f", withFocusedWindow(function(win)
          win:toggleFullScreen()
        end))

        -- Unlike native fullscreen above, this fills the screen without
        -- moving the window to its own Space.
        hyper:bind({ "shift" }, "f", withFocusedWindow(function(win)
          win:maximize(0)
        end))

        hyper:bind({}, "c", withFocusedWindow(function(win)
          win:centerOnScreen(nil, true, 0)
        end))

        local function moveWindowToDisplay(index)
          return withFocusedWindow(function(win)
            local target = hs.screen.allScreens()[index]
            if target then
              win:moveToScreen(target, false, true, 0)
            else
              hs.alert.show("display " .. index .. " is not connected")
            end
          end)
        end

        hyper:bind({ "shift" }, "1", moveWindowToDisplay(1))
        hyper:bind({ "shift" }, "2", moveWindowToDisplay(2))
        hyper:bind({ "shift" }, "3", moveWindowToDisplay(3))
      '';
    in
    {
      # Hammerspoon starts as a login item and may launch before the separate
      # Nix store volume is ready. Keep init.lua on the home volume instead of
      # exposing the usual Home Manager symlink into /nix/store.
      home.activation.installHammerspoonConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
        configDir="${config.home.homeDirectory}/.hammerspoon"
        configFile="$configDir/init.lua"
        stagingFile="$configDir/.init.lua.home-manager"

        configChanged=0
        if [[ -L "$configFile" ]] || ! /usr/bin/cmp -s "${hammerspoonConfig}" "$configFile"; then
          $DRY_RUN_CMD /usr/bin/install -d -m 0755 "$configDir"
          $DRY_RUN_CMD /usr/bin/install -m 0644 "${hammerspoonConfig}" "$stagingFile"
          $DRY_RUN_CMD /bin/mv -f "$stagingFile" "$configFile"
          configChanged=1
        fi

        # Never mutate live application state during a Home Manager dry run.
        # On a real activation, reload with a timeout so a wedged IPC server
        # cannot block the entire system switch. A fresh install is opened once
        # so init.lua can establish Hammerspoon's login item.
        if [[ "$configChanged" -eq 1 && -z "''${DRY_RUN_CMD:-}" ]]; then
          hsCli=/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
          if /usr/bin/pgrep -q Hammerspoon; then
            if [[ ! -x "$hsCli" ]] || ! ${lib.getExe' pkgs.coreutils "timeout"} 3 \
              "$hsCli" -c 'hs.reload()' >/dev/null 2>&1; then
              /usr/bin/killall Hammerspoon 2>/dev/null || true
              for _ in {1..20}; do
                /usr/bin/pgrep -q Hammerspoon || break
                /bin/sleep 0.1
              done
              /usr/bin/open -gj -a Hammerspoon
            fi
          elif [ -d /Applications/Hammerspoon.app ]; then
            /usr/bin/open -gj -a Hammerspoon
          fi
        fi
      '';
    };
}

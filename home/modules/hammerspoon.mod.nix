{ ... }:

{
  flake.homeModules.hammerspoon =
    { config, ... }:
    let
      statsPath = "${config.home.homeDirectory}/.local/state/input-stats.json";
    in
    {
      home.file.".hammerspoon/init.lua".text = /* lua */ ''
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

        -- cmd+alt+ctrl+S publishes current stats to melqtx.com
        local publishStatsScript = "/Users/melqtx/Documents/code/github/1337/bin/update-input-stats"
        hs.hotkey.bind({ "cmd", "alt", "ctrl" }, "S", function()
          flush()
          hs.notify.new({ title = "input stats", informativeText = "publishing..." }):send()
          hs.task.new("/bin/zsh", function(exitCode, stdOut, stdErr)
            local text
            if exitCode == 0 then
              text = stdOut:gsub("%s+$", "")
            else
              text = "failed: " .. stdErr:gsub("%s+$", "")
            end
            hs.notify.new({ title = "input stats", informativeText = text }):send()
          end, { "-lc", publishStatsScript }):start()
        end)

        -- Hyper layer: right cmd is remapped to F18 at the HID level (see
        -- darwin-defaults.mod.nix). Hold it for window-manager operations,
        -- mirroring the ctrl/cmd hjkl scheme used in zellij.
        local hyper = hs.hotkey.modal.new()
        hs.hotkey.bind({}, "f18", function()
          hyper:enter()
        end, function()
          hyper:exit()
        end)

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
      '';
    };
}

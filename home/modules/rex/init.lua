
local directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(directions) do
  rex.bind("ctrl+" .. key, "pane.focus", { direction = direction })
  rex.bind("ctrl+shift+" .. key, "pane.move", { direction = direction })
  rex.bind("alt+" .. key, "pane.split", { direction = direction })
  rex.bind("ctrl+alt+" .. key, "pane.resize", { direction = direction })
  rex.bind("ctrl+alt+shift+" .. key, "pane.resize", { direction = direction, amount = 15 })
end

rex.bind("alt+v", "pane.split", { direction = "right" })
rex.bind("alt+s", "pane.split", { direction = "down" })
rex.bind("cmd+t", "client.tab.new")
rex.bind("cmd+w", "client.tab.close")
rex.bind("cmd+r", "client.tab.rename")
rex.bind("cmd+h", "client.tab.previous")
rex.bind("cmd+l", "client.tab.next")
rex.bind("cmd+shift+h", "client.tab.previous")
rex.bind("cmd+shift+l", "client.tab.next")
rex.bind("cmd+shift+t", "client.tab.new")
rex.bind("cmd+shift+w", "client.tab.close")
rex.bind("ctrl+shift+w", "pane.close")
rex.bind("ctrl+f", "pane.zoom")
-- Float the current pane; Rex's native shortcuts handle its floating layers.
rex.bind("ctrl+shift+p", "pane.float")
-- Leave Ctrl+P/R/T/D/Q and Alt+C to Fish, Atuin, fzf, and terminal programs.

rex.action {
  name = "battle",
  title = "Open Battlestation",
  description = "five panes",
  run = function(ctx, args)
    local function shell()
      return rex.layout.block {
        flavor = "com.superlogical.terminal.shell",
        options = { cwd = args.cwd or (os.getenv("HOME") .. "/Documents/code") },
      }
    end
    local window, err = rex.session.new_window {
      session_id = ctx.session_id,
      window_label = "battlestation",
      layout = rex.layout.horizontal(0.30,
        rex.layout.vertical(0.5, shell(), shell()),
        rex.layout.horizontal(0.45 / 0.70,
          shell(),
          rex.layout.vertical(0.5, shell(), shell())
        )
      ),
    }
    if not window then error(err) end
    return window
  end,
  args = { cwd = "string?" },
}

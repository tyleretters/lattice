-- softclock wip

Softclock = include("lib/Softclock")

function init()
  -- basic softclock usage
  my_clock = Softclock:new(1, 8)
  -- subclock_a = my_clock:add(1/2, function() print("half notes") end)
  -- subclock_b = my_clock:add(1/4, function() print("quarter notes") end)

  -- -- optionally add a clock that is disabled
  -- subclock_c = my_clock:add( 1/8, function() print("eighth notes") end, false)

  -- -- run the clock
  my_clock_id = my_clock:run()

  -- user definable callbacks
  my_clock.advance_event = function(transport)
    print("advance event", transport)
  end
  my_clock.pulse_event = function()
    -- print("pulse event")
  end

  -- demo stuff
  screen_dirty = true
  redraw_clock_id = clock.run(redraw_clock)
end

function key(k, z)
  if z == 0 then return end
  if k == 2 then
    my_clock:toggle_subclock(subclock_a)
  elseif k == 3 then
    my_clock:toggle_subclock(subclock_b)
  end

  -- more api

  -- global clock controls
  -- my_clock:stop()
  -- my_clock:start()
  -- my_clock:toggle()

  -- individual clock controls
  -- my_clock:stop_subclock(subclock_a)
  -- my_clock:start_subclock(subclock_a)
  -- my_clock:toggle_subclock(subclock_a)

  -- remove subclocks
  -- my_clock:remove(subclock_a)
  -- my_clock:clear()
end

function enc(e, d)
  params:set("clock_tempo", params:get("clock_tempo") + d)
  screen_dirty = true
end

function cleanup()
  my_clock:cancel()
end

-- screen stuff

function redraw_clock()
  while true do
    clock.sleep(1/15)
    if screen_dirty then
      redraw()
      screen_dirty = false
    end
  end
end

function redraw()
  screen.clear()
  screen.level(15)
  screen.aa(0)
  screen.font_size(8)
  screen.font_face(0)
  screen.move(1, 8)
  screen.text(params:get("clock_tempo") .. " BPM")
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
-- lattice wip

-- lattice = include("lib/lattice")
lattice = require("lattice")

function init()
  -- basic lattice usage
  my_lattice = lattice:new()

  -- make some tracks
  track_a = my_lattice:new_track(1/2, function() print("half notes") end)
  track_b = my_lattice:new_track(1/4, function() print("quarter notes") end)

  -- optionally add a track that is disabled
  track_c = my_lattice:new_track(1/8, function() print("eighth notes") end, false)

  -- start the lattice
  my_lattice:start()

  -- user definable callbacks
  my_lattice.downbeat = function(transport)
    print("downbeat", transport)
  end

  -- another one, but in in 5/4 and 128 ppqn
  -- my_other_lattice = lattice:new(5, 128)

  -- demo stuff
  screen_dirty = true
  redraw_clock_id = clock.run(redraw_clock)
end

function key(k, z)
  if z == 0 then return end
  if k == 2 then
    track_a.toggle()
    track_b.toggle()
  elseif k == 3 then
    track_c.toggle()
  end

  -- more api

  -- global clock controls
  -- my_lattice:stop()
  -- my_lattice:start()
  -- my_lattice:toggle()
  -- my_lattice:destroy()
  -- my_lattice:set_meter(7)
  -- my_lattice:set_ppqn(48)

  -- individual track controls
  -- track_a.stop()
  -- track_a.start()
  -- track_a.toggle()
  -- track_a.destroy()
  -- track_a.set_division(1/7)

end

function enc(e, d)
  params:set("clock_tempo", params:get("clock_tempo") + d)
  screen_dirty = true
end

function cleanup()
  my_lattice:destroy()
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
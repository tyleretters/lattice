-- lattice wip

lattice = include("lib/lattice")
-- lattice = require("lattice")

function init()
  -- basic lattice usage (uses defaults)
  my_lattice = lattice:new()
  
  -- named params, each optional
  another_lattice = lattice:new{
    auto = false,
    meter = 5,
    ppqn = 128
  }

  -- make some patterns
  pattern_a = my_lattice:new_pattern{
    callback = function(t) print("whole notes", t) end,
    division = 1
  }
  pattern_b = my_lattice:new_pattern{
    callback = function(t) print("half notes", t) end,
    division = 1/2
  }
  pattern_c = my_lattice:new_pattern{
    callback = function(t) print("quarter notes", t) end,
    division = 1/4
  }
  pattern_d = my_lattice:new_pattern{
    callback = function(t) print("eighth notes", t) end,
    division = 1/8,
    enabled = false
  }

  -- start the lattice
  my_lattice:start()

  -- demo stuff
  screen_dirty = true
  redraw_clock_id = clock.run(redraw_clock)
end

function key(k, z)
  if z == 0 then return end
  if k == 2 then
    pattern_a:toggle()
    pattern_b:toggle()
  elseif k == 3 then
    pattern_c:toggle()
  end

  -- more api

  -- global lattice controls
  -- my_lattice:stop()
  -- my_lattice:start()
  -- my_lattice:toggle()
  -- my_lattice:destroy()
  -- my_lattice:set_meter(7)

  -- individual pattern controls
  -- pattern_a:stop()
  -- pattern_a:start()
  -- pattern_a:toggle()
  -- pattern_a:destroy()
  -- pattern_a:set_division(1/7)
  -- pattern_a:set_callback(function() print("change the callback") end)

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
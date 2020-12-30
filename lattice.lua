-- lattice wip

lattice = include("lib/lattice")
-- lattice = require("lattice")

function init()
  -- basic lattice usage (uses defaults)
  my_lattice = lattice:new()
  
  -- named params, each optional
  my_lattice = lattice:new{
    meter = 4,
    ppqn = 96,
    callback = function(t) print("transport position:", t) end
  }

  -- make some patterns
  pattern_a = my_lattice:new_pattern{
    division = 1/2,
    callback = function() print("half notes") end
  }
  pattern_b = my_lattice:new_pattern{
    division = 1/4,
    callback = function() print("quarter notes") end
  }
  pattern_c = my_lattice:new_pattern{
    division = 1/8,
    callback = function() print("eighth notes") end,
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
  -- my_lattice:destroy_pattern(pattern_a)
  -- my_lattice:set_meter(7)
  -- my_lattice:set_ppqn(48)
  -- my_lattice:set_callback(function() print("change the callback") end)

  -- individual pattern controls
  -- pattern_a:stop()
  -- pattern_a:start()
  -- pattern_a:toggle()
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
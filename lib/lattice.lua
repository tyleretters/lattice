--- module for creating a lattice of sprockets based on a single fast "superclock"
--
-- @module Lattice
-- @release v2.0.0
-- @author tyleretters & ezra & ryleelyman

local Lattice, Sprocket = {}, {}

--- instantiate a new lattice
-- @tparam[opt] table args optional named attributes are:
-- - "auto" (boolean) turn off "auto" pulses from the norns clock, defaults to true
-- - "ppqn" (number) the number of pulses per quarter note of this superclock, defaults to 96
-- @treturn table a new lattice
function Lattice:new(args)
  local l = setmetatable({}, { __index = Lattice })
  args = args == nil and {} or args
  l.auto = args.auto == nil and true or args.auto
  l.ppqn = args.ppqn == nil and 96 or args.ppqn
  l.enabled = false
  l.transport = 0
  l.superclock_id = nil
  l.sprocket_id_counter = 100
  l.sprockets = {}
  -- 5 levels of priority should be plenty tbh
  for i = 1, 5 do
      l.sprockets[i] = {}
  end
  return l
end

--- start running the lattice
function Lattice:start()
  if self.auto and self.superclock_id == nil then
    self.superclock_id = clock.run(self.auto_pulse, self)
  end
  self.enabled = true
end

--- stop the lattice
function Lattice:stop()
  self.enabled = false
end

--- toggle the lattice
function Lattice:toggle()
  self.enabled = not self.enabled
end

--- destroy the lattice
function Lattice:destroy()
  self:stop()
  if self.superclock_id ~= nil then
    clock.cancel(self.superclock_id)
  end
  self.sprockets = {}
end

--- set the meter of the lattice
-- @tparam number meter the meter the lattice counts
function Lattice:set_meter(_)
  print("this is deprecated; adjust pattern divisions instead")
end

--- use the norns clock to pulse
-- @tparam table s this lattice
function Lattice.auto_pulse(s)
  while true do
    s:pulse()
    clock.sync(1/s.ppqn)
  end
end

--- advance all sprockets in this lattice a single by pulse, call this manually if lattice.auto = false
function Lattice:pulse()
  if self.enabled then
    local ppm = self.ppqn * 4
    for i = 1, 5 do
      for _, sprocket in pairs(self.sprockets[i]) do
        if sprocket.enabled then
          sprocket.phase = sprocket.phase + 1
          if sprocket.phase > (sprocket.division * ppm) then
            sprocket.phase = sprocket.phase - (sprocket.division * ppm)
            sprocket.action(self.transport)
          end
        elseif sprocket.flag then
          self.sprockets[sprocket.id] = nil
        end
      end
    end
    self.transport = self.transport + 1
  end
end

--- factory method to add a new sprocket to this lattice
-- @tparam[opt] table args optional named attributes are:
-- - "action" (function) function called on each step of this division
-- - "division" (number) the division of the sprocket, defaults to 1/4
-- - "enabled" (boolean) is this sprocket enabled, defaults to true
-- @treturn table a new sprocket
function Lattice:new_sprocket(args)
  self.sprocket_id_counter = self.sprocket_id_counter + 1
  args = args == nil and {} or args
  args.id = self.sprocket_id_counter
  args.action = args.action == nil and function(t) return end or args.action
  args.division = args.division == nil and 1/4 or args.division
  args.enabled = args.enabled == nil and true or args.enabled
  args.phase_end = args.division * self.ppqn * 4
  args.priority = args.priority == nil and 3 or util.clamp(args.priority, 1, 5)
  local sprocket = Sprocket:new(args)
  self.sprockets[args.priority][self.sprocket_id_counter] = sprocket
  return sprocket
end

function Lattice:new_pattern(args)
    print("new_pattern is deprecated: use new_sprocket instead")
    return self:new_sprocket(args)
end

--- "private" method to instantiate a new sprocket, only called by Lattice:new_sprocket()
-- @treturn table a new sprocket
function Sprocket:new(args)
  local p = setmetatable({}, { __index = Sprocket })
  p.id = args.id
  p.division = args.division
  p.action = args.action
  p.enabled = args.enabled
  p.phase = args.phase_end
  p.flag = false
  return p
end

--- start the sprocket
function Sprocket:start()
  self.enabled = true
end

--- stop the sprocket
function Sprocket:stop()
  self.enabled = false
end

--- toggle the sprocket
function Sprocket:toggle()
  self.enabled = not self.enabled
end

--- flag the sprocket to be destroyed
function Sprocket:destroy()
  self.enabled = false
  self.flag = true
end

--- set the division of the sprocket
-- @tparam number n the division of the sprocket
function Sprocket:set_division(n)
   self.division = n
end

--- set the action for this sprocket
-- @tparam function the action
function Sprocket:set_action(fn)
  self.action = fn
end

return Lattice

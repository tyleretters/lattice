--  module for creating collections of soft-timers based on a single fast "superclock"
--
-- @module Softclock
-- @release v1.0.0
-- @author ezra & tyleretters

local Softclock = {}

--- instantiate a new softclock
-- @tparam[opt] number ppqn the number of pulses per quarter note of this superclock
function Softclock:new(ppqn)
  local s = setmetatable({}, { __index = Softclock })
  s.ppqn = ppqn ~= nil and ppqn or 128
  s.clock_id = nil
  s.clocks = {}
  s.transport = 0
  s.is_playing = true
  s.advance_event = nil -- advance callback
  s.pulse_event = nil -- pulse callback
  return s
end

--- start running the softclock
-- @return integer clock id
function Softclock:run()
  self.clock_id = clock.run(self.pulse, self)
  return self.clock_id
end

--- advance all subclocks in this softclock one by pulse
-- @tparam table s this softclock
function Softclock.pulse(s)
  while true do
    clock.sync(1/s.ppqn)
    -- really wish there was a continue statment...
    if s.is_playing then
      s.transport = s.transport + 1
      if s.advance_event ~= nil and s.transport % s.ppqn == 1 then
        s.advance_event(s.transport)
      end
      for id, clock in pairs(s.clocks) do
        if clock.is_playing then
          -- print might need to check if not nil for race conditions with remove()
          clock.phase_pulses = clock.phase_pulses + 1    
          -- asumption: subclock ppqn is > 1 pulse
          if clock.phase_pulses > clock.ppqn_pulses then
              clock.phase_pulses = clock.phase_pulses - clock.ppqn_pulses
              clock.event(clock.phase_pulses)
          end
        end
      end
      if s.pulse_event then
        s.pulse_event()
      end
    end
  end
end 

--- add a "subclock" to this softclock
-- @tparam string id unique identifier for this subclock
-- @tparam number ppqn the ppqn of the subclock
-- @tparam function event callback event
-- @tparam[opt] boolean is the subclock playing?
function Softclock:add(id, ppqn, event, playing)
    local c = {} -- new subclock table
    c.phase_pulses = 0
    c.ppqn_pulses = ppqn / (1/self.ppqn)
    c.event = event
    c.is_playing = playing ~= nil and playing or true
    self.clocks[id] = c
end

--- remove a subclock from this softclock
-- @tparam string unique identifier for this subclock
function Softclock:remove(id)
  self.clocks[id] = nil
end

--- change the ppqn of the softclock while running
-- @tparam number ppqn the ppqn of the superclock, in seconds
function Softclock:change_ppqn(ppqn)
  for id, clock in pairs(self.clocks) do
    clock.ppqn_pulses = (clock.ppqn_pulses * (1/self.ppqn)) / ppqn
  end
  self.ppqn = ppqn
end

--- cancel the softclock
function Softclock:cancel()
  clock.cancel(self.clock_id)
end

--- start the softclock
function Softclock:start()
  self.is_playing = true
end

--- stop the softclock
function Softclock:stop()
  self.is_playing = false
end

--- toggle the softclock
function Softclock:toggle()
  self.is_playing = not self.is_playing
end

--- start a subclock
-- @tparam string id unique identifier for this subclock
function Softclock:start_subclock(id)
  self.clocks[id].is_playing = true
end

--- stop a subclock
-- @tparam string id unique identifier for this subclock
function Softclock:stop_subclock(id)
  self.clocks[id].is_playing = false
end

--- toggle a subclock
-- @tparam string id unique identifier for this subclock
function Softclock:toggle_subclock(id)
  self.clocks[id].is_playing = not self.clocks[id].is_playing
end

return Softclock
local player_test = opencrypt.Creature:newChild()
local instances = {}

function player_test:new(...)
  local p = opencrypt.Creature.new(self, ...)

  setmetatable(p, self.metatable)
  table.insert(instances, p)
  return p
end

function player_test.setMoveEvent(e, x,y)
  e.addListener(function(pressed)
    if pressed then
      for _,p in ipairs(instances) do
        p:move(x,y)
      end
    end
  end)
end

function player_test:getDamage()
  return 1
end

function player_test:isStrong()
  return true
end

return player_test

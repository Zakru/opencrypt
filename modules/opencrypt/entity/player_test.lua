local player_test = opencrypt.Creature:newChild()
local instances = {}

function player_test:new(...)
  local p = opencrypt.Creature.new(self, ...)

  p.time = 0

  setmetatable(p, self.metatable)
  table.insert(instances, p)
  return p
end

function player_test:setAnimator(animator)
  self.animator = animator
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

function player_test:update(dt, world)
  self.time = self.time + dt
end

function player_test:draw(graphics, x,y)
  if self.animator then
    self.animator:draw(graphics, 1, self.time % 1, x,y)
  end
end

return player_test

local player_test = opencrypt.Creature:newChild()
player_test.lastBeat = 0
local instances = {}

local Camera = opencrypt.Entity:newChild()

function Camera:draw()
end

function player_test:new(...)
  local p = opencrypt.Creature.new(self, ...)

  p.camera = Camera:new(p.world, p.x,p.y)

  setmetatable(p, self.metatable)
  table.insert(instances, p)
  return p
end

function player_test:setAnimator(animator)
  self.animator = animator
end

function player_test:setMoveEvent(e, x,y)
  e.addListener(function(pressed)
    if pressed then
      local progress = player_test.animator.music:progressToNextBeat()
      local thisBeat = player_test.animator.music.beatIndex
      if progress < 0.5 then
        thisBeat = thisBeat - 1
      end
      if player_test.lastBeat < thisBeat then
        for _,p in ipairs(instances) do
          p:move(x,y)
        end
        player_test.stepEvent.call()
        player_test.lastBeat = thisBeat
      end
    end
  end)
end

function player_test:setStepEvent(e)
  self.stepEvent = e
end

function player_test:getDamage()
  return 1
end

function player_test:isStrong()
  return true
end

function player_test:update(dt, world)
  self.camera.x = self.x + (self.camera.x - self.x) * math.pow(0.001, dt)
  self.camera.y = self.y + (self.camera.y - self.y) * math.pow(0.001, dt)
end

function player_test:draw(graphics, x,y)
  if self.animator then
    self.animator:draw(graphics, 1, x,y)
  end
end

return player_test

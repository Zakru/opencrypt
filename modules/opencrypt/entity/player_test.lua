local entity = require('entity')

local player_test = entity.JumpCreature:newChild()
player_test.jumpHeight = 0.5
player_test.instances = {}

local Camera = opencrypt.Entity:newChild()

function Camera:draw()
end

function player_test:new(...)
  local p = entity.JumpCreature.new(self, ...)

  p.camera = Camera:new(p.world, p.x,p.y)
  p.flip = false
  p.lastBeat = 0

  setmetatable(p, self.metatable)
  table.insert(player_test.instances, p)
  return p
end

function player_test:setAnimator(animator)
  self.animator = animator
end

function player_test:setMoveEvent(e, x,y)
  e.addListener(function(pressed)
    if pressed then
      for _,p in ipairs(player_test.instances) do
        if not p.world.stop then
          local progress = player_test.animator.music:progressToNextBeat()
          local thisBeat = player_test.animator.music.beatIndex
          if progress < 0.5 then
            thisBeat = thisBeat - 1
          end
          if p.lastBeat < thisBeat then
            p:move(x,y)
            player_test.stepEvent.call()
            p.lastBeat = thisBeat
          end
        end
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

function player_test:move(x,y)
  local moved = entity.JumpCreature.move(self, x,y)

  if x ~= 0 then
    self.flip = x < 0
  end

  if moved then
    self.sprite.x = -x
    self.sprite.y = -y
  end
end

function player_test:update(dt, world)
  entity.JumpCreature.update(self, dt, world)

  self.camera.x = self.x + (self.camera.x - self.x) * math.pow(0.001, dt)
  self.camera.y = self.y + (self.camera.y - self.y) * math.pow(0.001, dt)
end

function player_test:destroy()
  for i,inst in ipairs(player_test.instances) do
    if inst == self then
      table.remove(player_test.instances, i)
      return
    end
  end
end

return player_test

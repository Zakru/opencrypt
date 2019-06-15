local player_test = opencrypt.Creature:newChild()
player_test.lastBeat = 0
player_test.jumpHeight = 0.5
local instances = {}

local Camera = opencrypt.Entity:newChild()

function Camera:draw()
end

function player_test:new(...)
  local p = opencrypt.Creature.new(self, ...)

  p.camera = Camera:new(p.world, p.x,p.y)
  p.sprite = {x=0,y=0}
  p.flip = false

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

function player_test:move(x,y)
  local moved = opencrypt.Creature.move(self, x,y)

  if x ~= 0 then
    self.flip = x < 0
  end

  if moved then
    self.sprite.x = -x
    self.sprite.y = -y
  end
end

function player_test:update(dt, world)
  self.camera.x = self.x + (self.camera.x - self.x) * math.pow(0.001, dt)
  self.camera.y = self.y + (self.camera.y - self.y) * math.pow(0.001, dt)

  local maxDist = 8 * dt
  local dx = math.min(math.max(-self.sprite.x, -maxDist), maxDist)
  local dy = math.min(math.max(-self.sprite.y, -maxDist), maxDist)
  self.sprite.x = self.sprite.x + dx
  self.sprite.y = self.sprite.y + dy
end

local function jumpHeightAt(d)
  d = math.max(d, 0)
  return 4 * (-d*d + d) * player_test.jumpHeight
end

function player_test:draw(graphics, x,y)
  local t = self.world.scale
  local d = math.sqrt(self.sprite.x*self.sprite.x + self.sprite.y*self.sprite.y)
  if self.animator then
    self.animator:draw(graphics, 1, x + self.sprite.x * t, y + (self.sprite.y - jumpHeightAt((d))) * t - 9, self.flip)
  end
end

return player_test

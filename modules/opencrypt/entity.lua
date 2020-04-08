[[
Copyright 2019 Zakru

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

-- StepCreature

local StepCreature = opencrypt.Creature:newChild()

function StepCreature:callStep(world)
  if not self.stepCalled then
    self.stepCalled = true
    self:step(world)
  end
end

function StepCreature:step(world)
end

-- JumpCreature

local JumpCreature = StepCreature:newChild()
JumpCreature.jumpHeight = 0.5

function JumpCreature:new(...)
  local jc = opencrypt.Creature.new(self, ...)

  jc.sprite = {x=0,y=0}
  jc.flip = false

  setmetatable(jc, self.metatable)
  return jc
end

function JumpCreature:move(x,y)
  local moved = opencrypt.Creature.move(self, x,y)

  if x ~= 0 then
    self.flip = x < 0
  end

  if moved then
    self.sprite.x = -x
    self.sprite.y = -y
  end

  return moved
end

function JumpCreature:jumpHeightAt(d)
  d = math.max(d, 0)
  return 4 * (-d*d + d) * self.jumpHeight
end

function JumpCreature:update(dt, world)
  opencrypt.Creature.update(self, dt, world)

  local maxDist = 8 * dt
  local dx = math.min(math.max(-self.sprite.x, -maxDist), maxDist)
  local dy = math.min(math.max(-self.sprite.y, -maxDist), maxDist)
  self.sprite.x = self.sprite.x + dx
  self.sprite.y = self.sprite.y + dy
end

function JumpCreature:getVisualOrigin(graphics)
  local d = math.sqrt(self.sprite.x*self.sprite.x + self.sprite.y*self.sprite.y)
  return (self.x - 1 + self.sprite.x) * graphics.tileSize, (self.y - 1 + self.sprite.y - self:jumpHeightAt((d))) * graphics.tileSize - 9
end

function JumpCreature:draw(graphics)
  local x,y = self:getVisualOrigin(graphics)
  if self.animator then
    self.animator:draw(graphics, 1, x, y, self.flip)
  else
    opencrypt.Creature.draw(self, graphics)
  end
end

local entity = {StepCreature = StepCreature, JumpCreature = JumpCreature}
return entity

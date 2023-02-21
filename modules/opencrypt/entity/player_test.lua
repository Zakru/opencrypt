--[[
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

local entity = selfRequire('entity')
local music = selfRequire('music')

local player_test = entity.JumpCreature:newChild()
player_test.jumpHeight = 0.5
player_test.shouldMove = false
player_test.nextMove = {0,0}

local Camera = opencrypt.Entity:newChild()

function Camera:draw()
end

function player_test:new(...)
  local p = entity.JumpCreature.new(self, ...)

  p.camera = Camera:new(p.world, p.x,p.y)
  p.flip = false
  p.lastBeat = 0

  setmetatable(p, self.metatable)
  return p
end

function player_test:setAnimator(animator)
  self.animator = animator
end

function player_test:setMoveEvent(e, x,y)
  e.addListener(function(pressed)
    if pressed then
      player_test.shouldMove = true
      player_test.nextMove = {x,y}
    end
  end)
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
  if player_test.shouldMove then
    player_test.shouldMove = false
    if not self.world.stop then
      local progress = self.animator.music:progressToNextBeat()
      local thisBeat = self.animator.music.beatIndex
      if progress < 0.5 then
        thisBeat = thisBeat - 1
      end
      if self.lastBeat < thisBeat then
        self:move(player_test.nextMove[1], player_test.nextMove[2])
        self.lastBeat = thisBeat
        if self.world:instanceOf(music.MusicWorld) then
          self.world:step()
        end
      end
    end
  end

  entity.JumpCreature.update(self, dt, world)

  self.camera.x = self.x + (self.camera.x - self.x) * math.pow(0.001, dt)
  self.camera.y = self.y + (self.camera.y - self.y) * math.pow(0.001, dt)
end

return player_test

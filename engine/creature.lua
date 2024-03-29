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

local Entity = require('engine/entity')
local Creature = Entity:newChild()
Creature.maxHealth = 1

function Creature:new(...)
  local e = Entity.new(self, ...)

  e.health = self.maxHealth

  return e
end

function Creature:newChild(maxHealth)
  local child = Entity.newChild(self)

  child.maxHealth = maxHealth

  return child
end

function Creature:onAttack(ent)
  if ent.getDamage then
    self.health = self.health - ent:getDamage()
    if self.health <= 0 then
      self.y = -10000
    end
  end
end

function Creature:willAttack(ent)
  return true
end

function Creature:move(x,y)
  local newx = self.x + x
  local newy = self.y + y
  if self:canMove(x,y) then
    local target = self.world:getFirstEntityAt(newx, newy)
    if target then
      if self:willAttack(target) then
        target:onAttack(self)
        return true
      end
    else
      Entity.move(self, x,y)
      self.world.tilemap:getTileAt(newx, newy):onWalkInto(self.world, newx,newy, self)
      return true
    end
  end
  self.world.tilemap:getTileAt(newx, newy):onWalkInto(self.world, newx,newy, self)
  return false
end

function Creature:isStrong()
  return false
end

return Creature

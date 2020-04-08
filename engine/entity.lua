local Type = require('engine/type')
local Entity = Type:newChild()

function Entity:new(world, x,y)
  local e = Type.new(self)

  e.world = world
  e.x = x
  e.y = y

  return e
end

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

function Entity:getVisualOrigin(graphics)
  return (self.x-1) * graphics.tileSize, (self.y-1) * graphics.tileSize
end

function Entity:draw(graphics)
  local x,y = self:getVisualOrigin(graphics)
  if self.texture then
    graphics.draw(self.texture, x,y)
  end
end

function Entity:canMove(x,y)
  local newx = self.x + x
  local newy = self.y + y

  local tile = self.world.tilemap:getTileAt(newx, newy)
  return tile and tile:isWalkable()
end

function Entity:move(x,y)
  local newx = self.x + x
  local newy = self.y + y
  local tile = self.world.tilemap:getTileAt(newx, newy)
  if tile and tile:isWalkable() then
    self.x = newx
    self.y = newy
    return true
  end
  return false
end

function Entity:isWalkable()
  return false
end

function Entity:update(dt)
end

function Entity:destroy()
end

return Entity

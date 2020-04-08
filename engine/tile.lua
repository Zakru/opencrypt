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

local Type = require('engine/type')

-- A Tile is a static object in the world, which can be used in a Tilemap
local Tile = Type:newChild()
Tile.layer = 1

function Tile:setTexture(texture)
  self.texture = texture
end

function Tile:isWalkable()
  return true
end

function Tile:draw(graphics, x,y)
  if self.texture then
    graphics.draw(self.texture, x*graphics.tileSize,y*graphics.tileSize)
  end
end

function Tile:onWalkInto(world, x,y, ent)
end

return Tile
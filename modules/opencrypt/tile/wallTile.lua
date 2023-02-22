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

local WallTile = opencrypt.Tile:newChild()
WallTile.layer = 2

function WallTile:draw(graphics, x,y)
  graphics.draw(self.texture, x*graphics.tileSize,y*graphics.tileSize-15)
end

function WallTile:isWalkable()
  return false
end

return WallTile

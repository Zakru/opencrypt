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

local WallTile = selfRequire('tile/wallTile')
local wall_breakable_test = WallTile:new()
wall_breakable_test.floorTile = nil

function wall_breakable_test:onWalkInto(world, x,y, ent)
  if ent.isStrong and ent:isStrong() then
    world.tilemap:setTileAt(x,y, self.floorTile)
  end
end

return wall_breakable_test
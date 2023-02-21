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

local stairs_down = opencrypt.Tile:new()
stairs_down.playerMeta = nil

function stairs_down:onWalkInto(world, x,y, ent)
  if getmetatable(ent) == stairs_down.playerMeta then
    self:onEnter()
  end
end

function stairs_down:onEnter()
end

return stairs_down

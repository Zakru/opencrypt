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

local Tile = require('engine/tile')
local Type = require('engine/type')

-- A Tilemap contains a palette of tiles and a 2D-table of numbers corresponding to the tiles in the palette
local Tilemap = Type:newChild()

local emptyTile = Tile:new()
function emptyTile:isWalkable()
  return false
end

function Tilemap:new(w,h)
  local t = Type.new(self)

  t.width=w
  t.height=h

  t.palette = {} -- Contains {tile, count}
  t.inversePalette = {} -- Contains indices to palette by tile
  t.tiles = {}
  for y=1,h do
    t.tiles[y] = {}
    for x=1,w do
      t.tiles[y][x] = 0
    end
  end

  return t
end

function Tilemap:getTileAt(x,y)
  if x < 1 or x > self.width or y < 1 or y > self.height then
    return emptyTile
  end

  local t = self.tiles[y][x]
  if t == 0 then
    return emptyTile
  else
    return self.palette[t].tile
  end
end

local function incrementIterator()
  local i = 0
  return function()
    i = i + 1
    return i
  end
end

local function firstFreePaletteIndex(map)
  for i in incrementIterator() do
    if map.palette[i] == nil then
      return i
    end
  end
end

function Tilemap:setTileAt(x,y, tile)
  if x < 1 or x > self.width or y < 1 or y > self.height then
    return
  end

  local t = self.tiles[y][x]
  if t ~= 0 and self.palette[t] and self.palette[t].count == 1 then
    self.inversePalette[self.palette[t].tile] = nil
    self.palette[t] = nil
  elseif t ~= 0 then
    self.palette[t].count = self.palette[t].count - 1
  end

  if tile ~= nil and self.palette[tile] == nil then
    local i = firstFreePaletteIndex(self)
    self.palette[i] = {tile=tile, count=1}
    self.inversePalette[tile] = i
  elseif tile ~= nil then
    self.palette[self.inversePalette[tile]].count = self.palette[self.inversePalette[tile]].count + 1
  end

  if tile ~= nil then
    self.tiles[y][x] = self.inversePalette[tile]
  else
    self.tiles[y][x] = 0
  end
end

return Tilemap

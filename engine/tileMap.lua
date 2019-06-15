local Tile = require('engine/tile')

-- A Tilemap contains a palette of tiles and a 2D-table of numbers corresponding to the tiles in the palette
local Tilemap = {}
Tilemap.metatable = {__index = Tilemap}

local emptyTile = Tile.new()
function emptyTile:isWalkable()
  return false
end

function Tilemap.new(w,h)
  local t = {}

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

  setmetatable(t, Tilemap.metatable)
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

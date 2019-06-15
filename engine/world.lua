-- A world is a combination of a Tilemap, entities and objects.
local World = {}
World.metatable = {__index = World}

function World.new(tilemap, scale)
  local w = {}

  w.tilemap = tilemap
  w.scale = scale -- Size of one tile
  w.entities = {}
  w.objects = {}

  setmetatable(w, World.metatable)
  return w
end

function World:forTiles(func)
  for y,row in ipairs(self.tilemap.tiles) do
    for x,ind in ipairs(row) do
      if ind ~= 0 then
        func(self.tilemap.palette[ind].tile, x,y)
      end
    end
  end
end

function World:forTileRows(func)
  for y,row in ipairs(self.tilemap.tiles) do
    func(row, y)
  end
end

function World:forTilesInRow(row, func)
  for x,ind in ipairs(row) do
    if ind ~= 0 then
      func(self.tilemap.palette[ind].tile, x)
    end
  end
end

function World:forEntitiesOnRow(y, func)
  for e,ent in ipairs(self.entities) do
    if ent.y == y then
      func(ent)
    end
  end
end

function World:getFirstEntityAt(x,y)
  for e,ent in ipairs(self.entities) do
    if ent.x == x and ent.y == y then
      return ent
    end
  end
  return nil
end

function World:spawn(entity)
  table.insert(self.entities, entity)
end

return World

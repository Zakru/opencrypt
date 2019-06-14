-- A world is a combination of a Tilemap, entities and objects.
local World = {}
World.metatable = {__index = World}

function World.new(tilemap, entities, objects, scale)
  local w = {}

  w.tilemap = tilemap
  w.entities = entities
  w.objects = objects
  w.scale = scale -- Size of one tile

  setmetatable(w, World.metatable)
  return w
end

function World:forTiles(func)
  for y,row in ipairs(self.tilemap.tiles) do
    for x,ind in ipairs(row) do
      if ind ~= 0 then
        print('func with ' .. ind)
        func(self.tilemap.palette[ind].tile, x,y)
      end
    end
  end
end

return World

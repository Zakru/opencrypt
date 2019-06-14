-- A world is a combination of a Tilemap, entities and objects.
local World
World.metatable = {__index = World}

function World.new(tilemap, entities, objects)
  local w = {}

  w.tilemap = tilemap
  w.entities = entities
  w.objects = objects

  setmetatable(w, World.metatable)
  return w
end

return World

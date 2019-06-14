-- A Tile is a static object in the world, which can be used in a Tilemap
local Tile = {}
Tile.metatable = {__index = Tile}

function Tile.new(id)
  local t = {namespace=opencrypt.namespace, id=id}

  setmetatable(t, Tile.metatable)
  return t
end

function Tile.isWalkable()

end

return Tile
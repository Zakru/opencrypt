-- A Tile is a static object in the world, which can be used in a Tilemap
local Tile = {}
Tile.metatable = {__index = Tile}
Tile.layer = 1

function Tile:new()
  local t = {}

  setmetatable(t, self.metatable)
  return t
end

function Tile:newChild()
  local child = {}
  child.metatable = {__index = child}

  setmetatable(child, self.metatable)
  return child
end

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
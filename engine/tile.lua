local Type = require('engine/type')

-- A Tile is a static object in the world, which can be used in a Tilemap
local Tile = Type:newChild()
Tile.layer = 1

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
local Type = require('engine/type')
local Entity = Type:newChild()

function Entity:new(world, x,y)
  local e = Type.new(self)

  e.world = world
  e.x = x
  e.y = y

  return e
end

function Entity:getVisualOrigin(graphics)
  return (self.x-1) * graphics.tileSize, (self.y-1) * graphics.tileSize
end

function Entity:draw(graphics)
  local x,y = self:getVisualOrigin(graphics)
  if self.texture then
    graphics.draw(self.texture, x,y)
  end
end

function Entity:canMove(x,y)
  local newx = self.x + x
  local newy = self.y + y

  local tile = self.world.tilemap:getTileAt(newx, newy)
  return tile and tile:isWalkable()
end

function Entity:move(x,y)
  local newx = self.x + x
  local newy = self.y + y
  local tile = self.world.tilemap:getTileAt(newx, newy)
  if tile and tile:isWalkable() then
    self.x = newx
    self.y = newy
    return true
  end
  return false
end

function Entity:isWalkable()
  return false
end

function Entity:update(dt)
end

function Entity:destroy()
end

return Entity

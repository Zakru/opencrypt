local Entity = {}
Entity.metatable = {__index = Entity}

function Entity:new(world, x,y)
  local e = {world=world, x=x,y=y}

  setmetatable(e, self.metatable)
  return e
end

function Entity:newChild()
  local child = {}
  child.metatable = {__index = child}

  setmetatable(child, self.metatable)
  return child
end

function Entity:draw(graphics, x,y)
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
  if self:canMove(x,y) then
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

return Entity

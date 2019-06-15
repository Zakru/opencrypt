local Entity = {}
Entity.metatable = {__index = Entity}

function Entity.new(world, x,y)
  local e = {world=world, x=x,y=y}

  setmetatable(e, Entity.metatable)
  return e
end

function Entity.newChild()
  local child = {}
  child.metatable = {__index = child}

  function child.new(...)
    local e = Entity.new(...)

    setmetatable(e, child.metatable)
    return e
  end

  setmetatable(child, Entity.metatable)
  return child
end

function Entity:draw(graphics, x,y)
  if self.texture then
    graphics.draw(self.texture, x,y)
  end
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
end

return Entity

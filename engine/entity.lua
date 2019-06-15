local Entity = {}
Entity.metatable = {__index = Entity}

function Entity.new(world, x,y)
  local e = {world=world, x=x,y=y}

  setmetatable(e, Entity.metatable)
  return e
end

function Entity:draw(graphics, x,y)
  if self.texture then
    graphics.draw(self.texture, x,y)
  end
end

function Entity:move(x,y)
  local newx = self.x + x
  local newy = self.y + y

  if self.world.tilemap:getTileAt(newx, newy):isWalkable() then
    self.x = newx
    self.y = newy
  end
end

return Entity

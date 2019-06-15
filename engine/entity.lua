local Entity = {}
Entity.metatable = {__index = Entity}

function Entity.new(x,y)
  local e = {x=x,y=y}

  setmetatable(e, Entity.metatable)
  return e
end

function Entity:draw(graphics, x,y)
  if self.texture then
    graphics.draw(self.texture, x,y)
  end
end

return Entity

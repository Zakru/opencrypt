local wall_test = opencrypt.Tile:new()
wall_test.layer = 2

function wall_test:draw(graphics, x,y)
  graphics.draw(self.texture, x*graphics.tileSize,y*graphics.tileSize-15)
end

function wall_test:isWalkable()
  return false
end

return wall_test
local wall_test = opencrypt.Tile:new()
wall_test.layer = 2

function wall_test:draw(graphics, x,y)
  opencrypt.Tile.draw(self, graphics, x,y-15)
end

function wall_test:isWalkable()
  return false
end

return wall_test
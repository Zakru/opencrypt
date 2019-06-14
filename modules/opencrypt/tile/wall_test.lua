local wall_test = opencrypt.Tile.new('wall_test')

function wall_test:draw(graphics, x,y)
  opencrypt.Tile.draw(self, graphics, x,y-15)
end

function wall_test:

return wall_test;
local wall_test = Tile.new('wall_test')

function wall_test.draw(graphics, x,y)
  graphics.draw(wall_test.texture, x,y-15)
end

return wall_test;
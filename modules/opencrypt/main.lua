local opencryptMod = opencrypt.Mod.new('opencrypt')

function opencryptMod:getInitialWorld()
  local image = love.graphics.newImage('modules/opencrypt/tile/floor_test.png')
  local tile = opencrypt.Tile.new('floor_test')
  opencrypt.registerTile(tile)
  function tile:draw(graphics, x,y)
    graphics.draw(image, x,y)
  end
  local t = opencrypt.Tilemap.new(10, 10)
  t:setTileAt(1,1, tile)
  return opencrypt.World.new(
    t,
    {},
    {},
    24
  )
end

return opencryptMod

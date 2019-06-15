local stairs_down = opencrypt.Tile:new()

function stairs_down:onWalkInto(world, x,y, ent)
  print('stairs')
  world:endWorld()
end

return stairs_down

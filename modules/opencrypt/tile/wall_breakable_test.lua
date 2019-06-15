local wall_breakable_test = opencrypt.Tile.new()
wall_breakable_test.layer = 2
wall_breakable_test.floorTile = nil

function wall_breakable_test:draw(graphics, x,y)
  opencrypt.Tile.draw(self, graphics, x,y-15)
end

function wall_breakable_test:isWalkable()
  return false
end

function wall_breakable_test:onWalkInto(world, x,y, ent)
  if ent.isStrong and ent:isStrong() then
    world.tilemap:setTileAt(x,y, self.floorTile)
  end
end

return wall_breakable_test
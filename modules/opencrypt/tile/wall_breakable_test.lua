local WallTile = selfRequire('tile/wallTile')
local wall_breakable_test = WallTile:new()
wall_breakable_test.floorTile = nil

function wall_breakable_test:onWalkInto(world, x,y, ent)
  if ent.isStrong and ent:isStrong() then
    world.tilemap:setTileAt(x,y, self.floorTile)
  end
end

return wall_breakable_test
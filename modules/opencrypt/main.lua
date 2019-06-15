local opencryptMod = opencrypt.Mod.new()

function opencryptMod:preLoad(registry)
  registry.registerKeybind('right', 'right')
  registry.registerKeybind('left', 'left')
  registry.registerKeybind('down', 'down')
  registry.registerKeybind('up', 'up')
end

function opencryptMod:postLoad(registered)
  self.registered = registered
  registered.entities.player_test.setMoveEvent(registered.keyevents.right, 1, 0)
  registered.entities.player_test.setMoveEvent(registered.keyevents.left, -1, 0)
  registered.entities.player_test.setMoveEvent(registered.keyevents.down,  0, 1)
  registered.entities.player_test.setMoveEvent(registered.keyevents.up,    0,-1)
end

function opencryptMod:getInitialWorld()
  local t = opencrypt.Tilemap.new(10, 10)
  for x=1,10 do
    for y=1,10 do
      if x == 1 or x == 10 or y == 1 or y == 10 then
        t:setTileAt(x,y, self.registered.tiles.wall_test)
      else
        t:setTileAt(x,y, self.registered.tiles.floor_test)
      end
    end
  end
  local world = opencrypt.World.new(t, 24)
  world:spawn(self.registered.entities.player_test.new(world, 5,5))
  return world
end

return opencryptMod

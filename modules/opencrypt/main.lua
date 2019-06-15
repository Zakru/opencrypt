local opencryptMod = opencrypt.Mod.new()

function opencryptMod:preLoad(registry)
  self.stepEvent = registry.registerEvent('step')

  self.rightEvent = registry.registerKeybind('right', 'right')
  self.leftEvent = registry.registerKeybind('left', 'left')
  self.downEvent = registry.registerKeybind('down', 'down')
  self.upEvent = registry.registerKeybind('up', 'up')
end

function opencryptMod:postLoad(registered)
  self.registered = registered
  registered.entities.player_test.setMoveEvent(self.rightEvent, 1, 0)
  registered.entities.player_test.setMoveEvent(self.leftEvent, -1, 0)
  registered.entities.player_test.setMoveEvent(self.downEvent,  0, 1)
  registered.entities.player_test.setMoveEvent(self.upEvent,    0,-1)

  registered.entities.enemy_test.giveStepEvent(self.stepEvent)

  function tryStep(pressed)
    if pressed then
      self.stepEvent.call()
    end
  end

  self.rightEvent.addListener(tryStep)
  self.leftEvent.addListener(tryStep)
  self.downEvent.addListener(tryStep)
  self.upEvent.addListener(tryStep)
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
  t:setTileAt(6,5, self.registered.tiles.wall_test)
  t:setTileAt(5,6, self.registered.tiles.wall_test)
  local world = opencrypt.World.new(t, 24)
  local player = self.registered.entities.player_test.new(world, 5,5)
  world:spawn(player)
  local enemy = self.registered.entities.enemy_test.new(world, 6,9)
  enemy:setTarget(player)
  world:spawn(enemy)
  return world
end

return opencryptMod

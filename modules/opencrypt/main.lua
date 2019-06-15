local opencryptMod = opencrypt.Mod.new()

function opencryptMod:getSubmodules()
  return {
    'animators',
    'music',
  }
end

function opencryptMod:preLoad(registry)
  self.stepEvent = registry.registerEvent('step')

  self.rightEvent = registry.registerKeybind('right', 'right')
  self.leftEvent = registry.registerKeybind('left', 'left')
  self.downEvent = registry.registerKeybind('down', 'down')
  self.upEvent = registry.registerKeybind('up', 'up')
end

function opencryptMod:postLoad(registered, resources)
  self.registered = registered
  self.resources = resources

  registered.tiles.wall_breakable_test.floorTile = registered.tiles.floor_test

  registered.entities.player_test:setMoveEvent(self.rightEvent, 1, 0)
  registered.entities.player_test:setMoveEvent(self.leftEvent, -1, 0)
  registered.entities.player_test:setMoveEvent(self.downEvent,  0, 1)
  registered.entities.player_test:setMoveEvent(self.upEvent,    0,-1)
  registered.entities.player_test:setStepEvent(self.stepEvent)

  local mus = self.music.Music:new(resources.sound['music_test.str.ogg'])
  mus:generateBeats(0, 0.5, 128)
  registered.entities.player_test:setAnimator(self.animators.MusicAnimator:new(mus, 1,4, registered.entities.player_test))

  registered.entities.enemy_test.giveStepEvent(self.stepEvent)
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
  t:setTileAt(6,5, self.registered.tiles.wall_breakable_test)
  t:setTileAt(5,6, self.registered.tiles.wall_breakable_test)
  local world = opencrypt.World.new(t, 24)
  local player = self.registered.entities.player_test:new(world, 5,5)
  world:spawn(player)
  local enemy1 = self.registered.entities.enemy_test:new(world, 6,9)
  enemy1:setTarget(player)
  world:spawn(enemy1)
  local enemy2 = self.registered.entities.enemy_test:new(world, 7,9)
  enemy2:setTarget(player)
  world:spawn(enemy2)
  local enemy3 = self.registered.entities.enemy_test:new(world, 6,7)
  enemy3:setTarget(player)
  world:spawn(enemy3)
  resources.sound['music_test.str.ogg']:play()
  world.track = player.camera
  return world
end

function opencryptMod:update(dt, world)
  local player_test = self.registered.entities.player_test
  local progress = player_test.animator.music:progressToNextBeat()
  local thisBeat = player_test.animator.music.beatIndex
  if progress < 0.5 then
    thisBeat = thisBeat - 1
  end
  if player_test.lastBeat < thisBeat - 1 then
    self.stepEvent.call()
    player_test.lastBeat = thisBeat - 1
  else
    player_test.canDoStep = player_test.lastBeat < thisBeat
  end
end

return opencryptMod

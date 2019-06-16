local opencryptMod = opencrypt.Mod.new()

local animators
local music
local mus

local wall_test
local floor_test
local wall_breakable_test
local stairs_down

local player_test
local enemy_test

function opencryptMod:preLoad(registry)
  animators = require('animators')
  music = require('music')

  self.stepEvent = registry.registerEvent('step')

  self.rightEvent = registry.registerKeybind('right', 'right')
  self.leftEvent = registry.registerKeybind('left', 'left')
  self.downEvent = registry.registerKeybind('down', 'down')
  self.upEvent = registry.registerKeybind('up', 'up')

  wall_test = require('tile/wall_test')
  registry.registerTile('wall_test', wall_test)
  floor_test = require('tile/floor_test')
  registry.registerTile('floor_test', floor_test)
  wall_breakable_test = require('tile/wall_breakable_test')
  registry.registerTile('wall_breakable_test', wall_breakable_test)
  stairs_down = require('tile/stairs_down')
  registry.registerTile('stairs_down', stairs_down)

  player_test = require('entity/player_test')
  registry.registerEntity('player_test', player_test)
  enemy_test = require('entity/enemy_test')
  registry.registerEntity('enemy_test', enemy_test)
end

function opencryptMod:postLoad(resources)
  self.registered = registered
  self.resources = resources

  wall_breakable_test.floorTile = floor_test

  player_test:setMoveEvent(self.rightEvent, 1, 0)
  player_test:setMoveEvent(self.leftEvent, -1, 0)
  player_test:setMoveEvent(self.downEvent,  0, 1)
  player_test:setMoveEvent(self.upEvent,    0,-1)
  player_test:setStepEvent(self.stepEvent)


  mus = music.Music:new(resources.sound['music_test.str.ogg'])
  mus:generateBeats(0, 0.5, 128)
  player_test:setAnimator(animators.MusicAnimator:new(mus, 1,4, player_test))

  enemy_test.giveStepEvent(self.stepEvent)
end

local function onWorldEnd(world)
  player_test.lastBeat = 0
end

local worldGenerator = {}

function worldGenerator:nextWorld()
  local t = opencrypt.Tilemap:new(12, 7)
  for x=1,12 do
    for y=1,7 do
      if x == 1 or x == 12 or y == 1 or y == 7 then
        t:setTileAt(x,y, wall_test)
      else
        t:setTileAt(x,y, floor_test)
      end
    end
  end
  t:setTileAt(10,4, stairs_down)
  local world = music.MusicWorld:new(mus, t, 24)
  local player = player_test:new(world, 4,4)
  world:spawn(player)
  local enemy1 = enemy_test:new(world, 9,3)
  enemy1:setTarget(player)
  world:spawn(enemy1)
  local enemy2 = enemy_test:new(world, 9,5)
  enemy2:setTarget(player)
  world:spawn(enemy2)
  world.track = player.camera
  world:addOnEndListener(onWorldEnd)
  return world
end

function opencryptMod:getInitialWorld()
  local t = opencrypt.Tilemap:new(7, 7)
  for x=1,7 do
    for y=1,7 do
      if x == 1 or x == 7 or y == 1 or y == 7 then
        t:setTileAt(x,y, wall_test)
      else
        t:setTileAt(x,y, floor_test)
      end
    end
  end
  t:setTileAt(4,5, stairs_down)
  local world = music.MusicWorld:new(mus, t, 24)
  local player = player_test:new(world, 4,3)
  world:spawn(player)
  world.track = player.camera
  world.nextGenerator = worldGenerator
  world:addOnEndListener(onWorldEnd)
  return world
end

function opencryptMod:update(dt, world)
  for player in iter(player_test.instances) do
    local progress = player.animator.music:progressToNextBeat()
    local thisBeat = player.animator.music.beatIndex
    if progress < 0.5 then
      thisBeat = thisBeat - 1
    end
    if player.lastBeat < thisBeat - 1 then
      self.stepEvent.call()
      player.lastBeat = thisBeat - 1
      break
    else
      player.canDoStep = player.lastBeat < thisBeat
    end
  end
end

return opencryptMod

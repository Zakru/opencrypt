--[[
Copyright 2019 Zakru

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

-- Assign opencrypt.Tile to a local variable for later use
local Tile = opencrypt.Tile
-- Require the mod's WallTile type
local WallTile = selfRequire('tile/wallTile')

-- Create mod object to be returned by this file
local opencryptMod = opencrypt.Mod.new()

-- Declare local variables. Every mod is loaded only once, and therefore
-- it should be safe to use locals, which look much cleaner in the code.

local animators
local music
local worldGenerator
local mus

local wall_test
local wall_brick
local floor_test
local wall_breakable_test
local stairs_down

local player_test
local enemy_test

local fadeDirection = 0
local fade = 0
local fading = false

local world

-- Called before any resources are loaded. Create all your object
-- instances here and register them.
function opencryptMod:preLoad(registry)
  -- Require additional modules. This must be done in preLoad or outside
  -- functions.
  animators = selfRequire('animators')
  music = selfRequire('music')
  worldGenerator = selfRequire('worldGenerator')

  -- Register events

  -- Register keybinds with their default keys. Default keys will be
  -- overridden with configuration.
  self.rightEvent = registry.registerKeybind('right', 'right')
  self.leftEvent = registry.registerKeybind('left', 'left')
  self.downEvent = registry.registerKeybind('down', 'down')
  self.upEvent = registry.registerKeybind('up', 'up')

  -- Register tiles
  wall_test = WallTile:new()
  registry.registerTile('wall_test', wall_test)
  wall_brick = WallTile:new()
  registry.registerTile('wall_brick', wall_brick)
  floor_test = Tile:new()
  registry.registerTile('floor_test', floor_test)
  floor_brick = Tile:new()
  registry.registerTile('floor_brick', floor_brick)

  -- These tiles are special, so the files already return the tile instances
  stairs_down = selfRequire('tile/stairs_down')
  registry.registerTile('stairs_down', stairs_down)
  wall_breakable_test = selfRequire('tile/wall_breakable_test')
  registry.registerTile('wall_breakable_test', wall_breakable_test)

  -- Register entities
  player_test = selfRequire('entity/player_test')
  registry.registerEntity('player_test', player_test)
  enemy_test = selfRequire('entity/enemy_test')
  registry.registerEntity('enemy_test', enemy_test)

  music.MusicWorld.playerType = player_test
  worldGenerator.floor = floor_brick
  worldGenerator.wall = wall_brick
  worldGenerator.player = player_test
end

-- Placeholder for now. Register event listeners here. This function is
-- called during resource loading. During this period, resources such as
-- textures for registered entities are loaded, along with everything in
-- the mod's `resource` folder. References to other mods' objects should
-- be handled here, as well.
function opencryptMod:load(registry)
end

-- The function called after all resources have been loaded. The single
-- argument is a table containing the resource pointers with their path
-- inside the resource folder being the key.
function opencryptMod:postLoad(resources)
  -- Save resources for later use
  self.resources = resources

  -- Set the tile wall_breakable_test breaks down to
  wall_breakable_test.floorTile = floor_test

  -- Set the metatable stairs_down should be looking for
  stairs_down.playerMeta = player_test.metatable
  -- Set stairs_down enter handler
  function stairs_down:onEnter()
    fadeDirection = 1
    fading = true
    world.stop = true
  end

  -- Add key event handlers to player_test
  player_test:setMoveEvent(self.rightEvent, 1, 0)
  player_test:setMoveEvent(self.leftEvent, -1, 0)
  player_test:setMoveEvent(self.downEvent,  0, 1)
  player_test:setMoveEvent(self.upEvent,    0,-1)

  -- Create a Music instance from the test music
  mus = music.Music:new(resources['music_test.str.ogg'])
  worldGenerator.music = mus
  -- Generate the beats for the music (just generates beats with a start
  -- time, interval and count, doesn't actually automatically generate
  -- the beats from the music)
  mus:beatsFromFile(resources['music_test.mus'])
  -- Set player_test's animation to follow the music's beats
  player_test:setAnimator(animators.MusicAnimator:new(mus, 1,4, player_test))
end

-- Called when a world this handler is assigned to ends
local function onWorldEnd(world)
  -- Reset player_test's last beat
  player_test.lastBeat = 0
end

-- Called when the engine is requesting a lobby/menu world. Should
-- return a world. The first world the engine gets will be used. See
-- above for world generation.
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
  world = music.MusicWorld:new(mus, t, 24)
  local player = player_test:new(world, 4,3)
  world:spawn(player)
  world.track = player.camera
  world.nextGenerator = worldGenerator
  world:addOnEndListener(onWorldEnd)
  return world
end

-- Called every frame with the delta time and active world
function opencryptMod:update(dt, world)
  world.freeze = fading

  -- If fading out, set music volume to amount of visibility
  if fadeDirection > 0 then
    mus.instance:setVolume(1-fade)
  end

  -- If completely faded out, end current world and begin to fade in
  if fade == 1 and fadeDirection > 0 then
    fadeDirection = -1
    fading = false
    world:endWorld()
  end

  -- Update fade
  fade = math.max(math.min(fade + fadeDirection * dt * 2, 1), 0)
end

-- Called for every mod during love.draw
function opencryptMod:draw()
  -- Overlay the screen with the fadeout
  love.graphics.setColor(0,0,0, fade)
  love.graphics.rectangle('fill', 0,0, love.graphics.getDimensions())
  love.graphics.setColor(1,1,1)
end

return opencryptMod

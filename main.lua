local RenderEngine = require('engine/renderEngine')
local modloader = require('modloader')
require('util')

local process = {}

_G.opencrypt = {
  Tile = require('engine/tile'),
  Mod = require('engine/mod'),
  World = require('engine/world'),
  Tilemap = require('engine/tilemap'),
  Entity = require('engine/entity'),
  Creature = require('engine/creature'),
}

local loadFirstInitialWorld

local function onWorldEnd(world)
  if world == process.renderer.world then
    if world.nextGenerator then
      process.renderer.world = world.nextGenerator:nextWorld()
      if process.renderer.world == nil then
        loadFirstInitialWorld()
        return
      end
    elseif world.nextWorld then
      process.renderer.world = world.nextWorld
    else
      loadFirstInitialWorld()
      return
    end

    process.renderer.world:addOnEndListener(onWorldEnd)
    process.renderer.world:begin()
  end
end

loadFirstInitialWorld = function()
  process.renderer.world = modloader.getInitialWorld()
  process.renderer.world:addOnEndListener(onWorldEnd)
  process.renderer.world:begin()
end

function love.load()
  process.renderer = RenderEngine.new()
  modloader.load()
  loadFirstInitialWorld()
end

function love.update(dt)
  modloader.update(dt, process.renderer.world)
end

function love.draw()
  process.renderer:render()
end

function love.keypressed(key, _, isrepeat)
  if not isrepeat then
    modloader.handleKey(key, true)
  end
end

function love.keyreleased(key)
  if not isrepeat then
    modloader.handleKey(key, false)
  end
end

if arg[2] == '--test' then
  function love.draw()
      process.renderer:render()
    love.event.quit()
  end
end

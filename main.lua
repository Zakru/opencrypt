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

local RenderEngine = require('engine/renderEngine')
local modloader = require('modloader')
require('util')

local process = {}

_G.opencrypt = {
  Type = require('engine/type'),
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
  modloader.draw()
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

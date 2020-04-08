[[
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

-- The modloader module keeps track of every mod and their content
local modloader = {}
modloader.mods = {}
modloader.tiles = {}
modloader.entities = {}
modloader.generators = {}
modloader.events = {}
modloader.keybinds = {}
modloader.keyevents = {}

local Tile = require('engine/tile')
local Mod = require('engine/mod')
local World = require('engine/world')
local Tilemap = require('engine/tilemap')
local Entity = require('engine/entity')
local Creature = require('engine/creature')
local Resource = require('engine/resource')

local function registerTileFactory(namespace)
  return function(id, tile)
    if not modloader.tiles[namespace] then modloader.tiles[namespace] = {} end
    modloader.tiles[namespace][id] = tile
    tile.registeredNamespace = namespace
    tile.registeredId = id
  end
end

local function registerEntityFactory(namespace)
  return function(id, entity)
    if not modloader.entities[namespace] then modloader.entities[namespace] = {} end
    modloader.entities[namespace][id] = entity
    entity.registeredNamespace = namespace
    entity.registeredId = id
  end
end

local function registerGeneratorFactory(namespace)
  return function(id, generator)
    if not modloader.generators[namespace] then modloader.generators[namespace] = {} end
    modloader.generators[namespace][id] = generator
  end
end

local function registerEventFactory(namespace)
  return function(id)
    if not modloader.events[namespace] then modloader.events[namespace] = {} end
    local e = {}
    e.listeners = {}
    modloader.events[namespace][id] = e

    function e.addListener(listener)
      table.insert(e.listeners, listener)
    end

    function e.call(...)
      for l,listener in ipairs(e.listeners) do
        listener(...)
      end
    end

    return e
  end
end

local function registerKeybindFactory(namespace)
  return function(id, defaultKey)
    if not modloader.keyevents[namespace] then modloader.keyevents[namespace] = {} end
    local e = {}
    e.listeners = {}
    e.keybind = {key=defaultKey, event=e}
    modloader.keyevents[namespace][id] = e

    function e.addListener(listener)
      table.insert(e.listeners, listener)
    end

    table.insert(modloader.keybinds, e.keybind)

    return e
  end
end

local function safeCall(modId, func, ...)
  if arg[2] == '--test' then
    local status, err, ret xpcall(function()
      func(unpack(args))
    end, function(err)
      print(err)
    end)
    if status then
      return status, err, ret
    end
    love.event.quit(1)
  end
  local args = ... or {}
  return xpcall(function()
    func(unpack(args))
  end, function(err)
    modloader.mods[modId] = nil
    print(err)
  end)
end

local function getMod(name)
  return modloader.mods[name]
end

local _require
local function loadGlobals(prefix)
  _G.selfRequire = function(path)
    return require(prefix .. path)
  end
end

local function unloadGlobals()
  _G.selfRequire = nil
end

function modloader.load()
  _G.modRequire = function(mod, path)
    return require('modules/' .. mod .. '/' .. path)
  end

  local modDirs = love.filesystem.getDirectoryItems('modules')

  -- Load modules
  for _,namespace in ipairs(modDirs) do
    local status, _,_ = safeCall(namespace, function()
      local modMain = love.filesystem.getInfo('modules/' .. namespace .. '/main.lua')

      -- If the module has a main.lua, require its return value
      if modMain and modMain.type == 'file' then
        loadGlobals('modules/' .. namespace .. '/')
        -- Require the mod
        modloader.mods[namespace] = modRequire(namespace, 'main')

        -- PRELOAD MOD
        modloader.mods[namespace]:preLoad({
          registerEvent=registerEventFactory(namespace),
          registerKeybind=registerKeybindFactory(namespace),
          registerTile=registerTileFactory(namespace),
          registerEntity=registerEntityFactory(namespace),
          registerGenerator=registerGeneratorFactory(namespace),
        })

        -- Unload globals
        unloadGlobals()
      end
    end)

    if not status then
      print(namespace .. ': An error occurred and this mod was disabled.')
    end
  end

  for _,namespace in ipairs(modloader.mods) do
    modloader.mods[namespace]:load({
      registerEventListener=registerEventListener,
    })
  end

  -- LOAD RESOURCES
  love.graphics.setDefaultFilter('linear', 'nearest')

  -- Tiles
  for namespace, tiles in pairs(modloader.tiles) do
    for id, tile in pairs(tiles) do
      tile.texture = love.graphics.newImage('modules/' .. namespace .. '/tile/' .. id .. '.png')
    end
  end

  -- Entities
  for namespace, entities in pairs(modloader.entities) do
    for id, entity in pairs(entities) do
      entity.texture = love.graphics.newImage('modules/' .. namespace .. '/entity/' .. id .. '.png')
    end
  end

  -- Load miscellaneous resources
  for namespace, mod in pairs(modloader.mods) do
    local resources = {}
    for _,filename in ipairs(love.filesystem.getDirectoryItems('modules/' .. namespace .. '/resource')) do
      resources[filename] = Resource:new('modules/' .. namespace .. '/resource/' .. filename)
    end

    modloader.mods[namespace]:postLoad(resources)
  end
end

function modloader.getInitialWorld()
  for id,mod in pairs(modloader.mods) do
    local initialWorld = mod:getInitialWorld()
    if initialWorld then
      return initialWorld
    end
  end
  return nil
end

function modloader.update(dt, world)
  for id,mod in pairs(modloader.mods) do
    mod:preUpdate(dt, world)
  end
  if world then
    world:update(dt)
  end
  for id,mod in pairs(modloader.mods) do
    mod:update(dt, world)
  end
end

function modloader.draw()
  for id,mod in pairs(modloader.mods) do
    mod:draw()
  end
end

function modloader.handleKey(key, pressed)
  for _,keybind in ipairs(modloader.keybinds) do
    if keybind.key == key then
      for l,listener in ipairs(keybind.event.listeners) do
        listener(pressed)
      end
    end
  end
end

return modloader

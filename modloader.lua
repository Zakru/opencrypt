-- The modloader module keeps track of every mod and their content
local modloader = {}
modloader.mods = {}
modloader.tiles = {}
modloader.entities = {}
modloader.objects = {}
modloader.generators = {}
modloader.events = {}

local Tile    = require('engine/tile')
local Mod     = require('engine/mod')
local World   = require('engine/world')
local Tilemap = require('engine/tilemap')
local Entity  = require('engine/entity')

local function registerTile(namespace, id, tile)
  if not modloader.tiles[namespace] then modloader.tiles[namespace] = {} end
  modloader.tiles[namespace][id] = tile
end

local function registerEntity(namespace, id, entity)
  if not modloader.entities[namespace] then modloader.entities[namespace] = {} end
  modloader.entities[namespace][id] = entity
end

local function registerObject(namespace, id, object)
  if not modloader.objects[namespace] then modloader.objects[namespace] = {} end
  modloader.objects[namespace][id] = object
end

local function registerGenerator(namespace, id, generator)
  if not modloader.generators[namespace] then modloader.generators[namespace] = {} end
  modloader.generators[namespace][id] = generator
end

local function registerEventFactory(namespace)
  return function(id)
    if not modloader.events[namespace] then modloader.events[namespace] = {} end
    local e = {}
    modloader.events[namespace][id] = e
    return function(...)
      for l,listener in ipairs(e) do
        listener(...)
      end
    end
  end
end

local function registerEventListener(namespace, id, listener)
  if modloader.events[namespace] and modloader.events[namespace][id] then
    table.insert(modloader.events[namespace][id], listener)
  end
end

local function loadGlobals()
  _G['opencrypt'] = {
    Tile=Tile,
    Mod=Mod,
    World=World,
    Tilemap=Tilemap,
    Entity=Entity,
  }
end

local function unloadGlobals()
  _G['opencrypt'] = nil
end

function modloader.withGlobals(cb)
  if not opencrypt then
    loadGlobals()
    cb()
    unloadGlobals()
  else
    cb()
  end
end

function modloader.load()
  local modDirs = love.filesystem.getDirectoryItems('modules')

  -- Iterate over module directories
  for _,namespace in ipairs(modDirs) do
    local modMain = love.filesystem.getInfo('modules/' .. namespace .. '/main.lua')

    -- If the module has a main.lua, require its return value
    if modMain and modMain.type == 'file' then
      -- Load global variables with the namespace set to the mod's directory
      loadGlobals()
      love.graphics.setDefaultFilter('linear', 'nearest')
      -- Require the mod
      modloader.mods[namespace] = require('modules/' .. namespace .. '/main')
      modloader.mods[namespace]:preLoad({
        registerEvent=registerEventFactory(namespace),
      })

      -- LOAD RESOURCES
      local registered = {}

      -- Load tiles
      registered.tiles = {}
      for _,filename in ipairs(love.filesystem.getDirectoryItems('modules/' .. namespace .. '/tile')) do
        if filename:match('%.lua$') then
          tileId = filename:sub(1, -5)
          local tile = require('modules/' .. namespace .. '/tile/' .. tileId)
          tile:setTexture(love.graphics.newImage('modules/' .. namespace .. '/tile/' .. tileId .. '.png'))
          registered.tiles[tileId] = tile
          registerTile(namespace, tileId, tile)
        end
      end

      -- Load entities
      registered.entities = {}
      for _,filename in ipairs(love.filesystem.getDirectoryItems('modules/' .. namespace .. '/entity')) do
        if filename:match('%.lua$') then
          entityId = filename:sub(1, -5)
          local entity = require('modules/' .. namespace .. '/entity/' .. entityId)
          entity.texture = love.graphics.newImage('modules/' .. namespace .. '/entity/' .. entityId .. '.png')
          registered.entities[entityId] = entity
          registerEntity(namespace, entityId, entity)
        end
      end

      -- Load objects
      registered.objects = {}
      for _,filename in ipairs(love.filesystem.getDirectoryItems('modules/' .. namespace .. '/object')) do
        if filename:match('%.lua$') then
          objectId = filename:sub(1, -5)
          local object = require('modules/' .. namespace .. '/object/' .. objectId)
          entity.texture = love.graphics.newImage('modules/' .. namespace .. '/object/' .. objectId .. '.png')
          registered.objects[objectId] = object
          registerEntity(namespace, objectId, object)
        end
      end

      modloader.mods[namespace]:load({
        registerEventListener=registerEventListener,
      })

      modloader.mods[namespace]:postLoad(registered)

      -- Unload globals
      unloadGlobals()
    end
  end
end

function modloader.getInitialWorld()
  for id,mod in pairs(modloader.mods) do
    loadGlobals(id)
    local initialWorld = mod:getInitialWorld()
    if initialWorld then
      unloadGlobals()
      return initialWorld
    end
  end

  unloadGlobals()
  return nil
end

return modloader

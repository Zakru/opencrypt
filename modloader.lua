-- The modloader module keeps track of every mod and their content
local modloader = {}
modloader.mods = {}
modloader.tiles = {}
modloader.entities = {}
modloader.objects = {}

local Tile = require('engine/tile')
local Mod  = require('engine/mod')
local World  = require('engine/world')
local Tilemap  = require('engine/tilemap')

local function registerTile(namespace)
  return function(tile)
    modloader.tiles[namespace .. ':' .. tile.id] = tile
  end
end

local function registerEntity(namespace)
  return function(entity)
    modloader.entities[namespace .. ':' .. entity.id] = entity
  end
end

local function registerObject(namespace)
  return function(object)
    modloader.objects[namespace .. ':' .. object.id] = object
  end
end

local function registerGenerator(namespace)
  return function(id, generator)
    modloader.generators[namespace .. ':' .. id] = generator
  end
end

local function loadGlobals(namespace)
  _G['opencrypt'] = {
    Tile=Tile,
    Mod=Mod,
    World=World,
    Tilemap=Tilemap,
    registerTile=registerTile(namespace),
    registerEntity=registerEntity(namespace),
    registerObject=registerObject(namespace),
    registerGenerator=registerGenerator(namespace),
    namespace=namespace,
  }
end

local function unloadGlobals()
  _G['opencrypt'] = nil
end

function modloader.load()
  local modDirs = love.filesystem.getDirectoryItems('modules')

  -- Iterate over module directories
  for _,modDir in ipairs(modDirs) do
    local modMain = love.filesystem.getInfo('modules/' .. modDir .. '/main.lua')

    -- If the module has a main.lua, require its return value
    if modMain and modMain.type == 'file' then
      -- Load global variables with the namespace set to the mod's directory
      loadGlobals(modMain)
      love.graphics.setDefaultFilter('linear', 'nearest')
      -- Require the mod
      modloader.mods[modDir] = require('modules/' .. modDir .. '/main')
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

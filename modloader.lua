-- The modloader module keeps track of every mod and their content
local modloader = {}
modloader.mods = {}
modloader.tiles = {}
modloader.entities = {}
modloader.objects = {}
modloader.generators = {}
modloader.events = {}
modloader.keybinds = {}
modloader.keyevents = {}

local Tile = require('engine/tile')
local Mod = require('engine/mod')
local World = require('engine/world')
local Tilemap = require('engine/tilemap')
local Entity = require('engine/entity')
local Creature  = require('engine/creature')

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

local function registerEventFactory(registered, namespace)
  return function(id)
    if not modloader.events[namespace] then modloader.events[namespace] = {} end
    local e = {}
    e.listeners = {}
    modloader.events[namespace][id] = e
    registered.events[id] = e

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

local function registerKeybindFactory(registered, namespace)
  return function(id, defaultKey)
    if not modloader.keyevents[namespace] then modloader.keyevents[namespace] = {} end
    local e = {}
    e.listeners = {}
    e.keybind = {key=defaultKey, event=e}
    modloader.keyevents[namespace][id] = e
    registered.keyevents[id] = e

    function e.addListener(listener)
      table.insert(e.listeners, listener)
    end

    table.insert(modloader.keybinds, e.keybind)

    return e
  end
end

local function safeCall(modId, func, ...)
  local args = ... or {}
  return xpcall(function()
    func(unpack(args))
  end, function(err)
    modloader.mods[modId] = nil
    print(err)
  end)
end

local function loadGlobals()
  _G['opencrypt'] = {
    Tile=Tile,
    Mod=Mod,
    World=World,
    Tilemap=Tilemap,
    Entity=Entity,
    Creature=Creature,
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
    local status, _,_ = safeCall(namespace, function()
      local modMain = love.filesystem.getInfo('modules/' .. namespace .. '/main.lua')

      -- If the module has a main.lua, require its return value
      if modMain and modMain.type == 'file' then
        -- Load global variables with the namespace set to the mod's directory
        loadGlobals()
        love.graphics.setDefaultFilter('linear', 'nearest')
        -- Require the mod
        modloader.mods[namespace] = require('modules/' .. namespace .. '/main')
        for path in iter(modloader.mods[namespace]:getSubmodules()) do
          modloader.mods[namespace][path] = require('modules/' .. namespace .. '/' .. path)
          modloader.mods[namespace][path].mod = modloader.mods[namespace]
        end

        -- LOAD RESOURCES
        local registered = {}
        registered.events = {}
        registered.keyevents = {}
        modloader.mods[namespace]:preLoad({
          registerEvent=registerEventFactory(registered, namespace),
          registerKeybind=registerKeybindFactory(registered, namespace),
        })

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
    end)

    if not status then
      print(namespace .. ': An error occurred and this mod was disabled.')
    end
  end
end

function modloader.getInitialWorld()
  for id,mod in pairs(modloader.mods) do
    loadGlobals()
    local initialWorld = mod:getInitialWorld()
    if initialWorld then
      unloadGlobals()
      return initialWorld
    end
  end

  unloadGlobals()
  return nil
end

function modloader.update(dt, world)
  for id,mod in pairs(modloader.mods) do
    loadGlobals()
    mod:preUpdate(dt, world)
  end
  loadGlobals()
  if world then
    world:update()
  end
  for id,mod in pairs(modloader.mods) do
    loadGlobals()
    mod:update(dt, world)
  end
  unloadGlobals()
end

function modloader.handleKey(key, pressed)
  modloader.withGlobals(function()
    for _,keybind in ipairs(modloader.keybinds) do
      if keybind.key == key then
        for l,listener in ipairs(keybind.event.listeners) do
          listener(pressed)
        end
      end
    end
  end)
end

return modloader

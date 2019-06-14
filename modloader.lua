-- The modloader module keeps track of every mod and their content
local modloader = {}
modloader.tiles = {}
modloader.entities = {}
modloader.objects = {}

local Tile = require('engine/tile')
local Mod  = require('engine/mod')

local function registerTile(namespace)
  return function(tile)
    tiles[namespace .. ':' .. tile.id]
  end
end

local function loadGlobals(namespace)
  _G['opencrypt'] = {
    Tile=Tile,
    Mod=Mod,
    registerTile=registerTile,
    namespace=namespace,
  }
end

local function unloadGlobals()
  _G['opencrypt'] = nil
end

function modloader.load()
  local modDirs = love.filesystem.getDirectoryItems('modules')
  local mods = {}

  -- Iterate over module directories
  for _,modDir in ipairs(modDirs) do
    local modMain = love.filesystem.getInfo('modules/' .. modDir .. '/main.lua')

    -- If the module has a main.lua, require its return value
    if modMain and modMain.type == 'file' then
      -- Load global variables with the namespace set to the mod's directory
      loadGlobals(modMain)
      -- Require the mod
      mods[modDir] = require('modules/' .. modDir .. '/main')
      -- Unload globals
    end
  end
end

return modloader

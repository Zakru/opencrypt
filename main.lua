local RenderEngine = require('engine/renderEngine')
local modloader = require('modloader')

local process = {}

function love.load()
  process.renderer = RenderEngine.new()
  modloader.load()
  process.renderer.world = modloader.getInitialWorld()
end

function love.update(dt)
  modloader.update(dt, process.renderer.world)
end

function love.draw()
  modloader.withGlobals(function()
    process.renderer:render()
  end)
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

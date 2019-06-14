local RenderEngine = require('engine/renderEngine')
local modloader = require('modloader')

local process = {}

function love.load()
  process.renderer = RenderEngine.new()
  modloader.load()
  process.renderer.world = modloader.getInitialWorld()
end

function love.update(dt)

end

function love.draw()
  process.renderer:render()
end

-- A RenderEngine holds a world which it can render and controls the rendering process
local RenderEngine = {}
RenderEngine.metatable = {__index = RenderEngine}

function RenderEngine.new()
  local re = {}

  setmetatable(re, RenderEngine.metatable)
  return re
end

function RenderEngine.render()
  -- Prepare rendering by setting general state
end

return RenderEngine

local Mod = {}
Mod.metatable = {__index = Mod}

function Mod.new()
  local m = {}

  setmetatable(m, Mod.metatable)
  return m
end

function Mod:getInitialWorld()
  return nil
end

function Mod:preLoad()
end

function Mod:load()
end

function Mod:postLoad()
end

function Mod:preUpdate(dt, world)
end

function Mod:update(dt, world)
end

return Mod

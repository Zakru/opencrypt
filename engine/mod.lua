local Mod = {}
Mod.metatable = {__index = Mod}

function Mod.new(id)
  local m = {}

  m.id = id

  setmetatable(m, Mod.metatable)
  return m
end

function Mod:getInitialWorld()
  return nil
end

return Mod

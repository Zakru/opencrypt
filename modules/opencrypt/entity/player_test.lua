local player_test = {}
player_test.metatable = {__index = player_test}

function player_test.new(...)
  local p = opencrypt.Entity.new(...)

  setmetatable(p, player_test.metatable)
  return p
end

setmetatable(player_test, opencrypt.Entity.metatable)
return player_test

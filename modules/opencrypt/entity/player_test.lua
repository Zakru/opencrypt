local player_test = opencrypt.Entity.newChild()
local instances = {}

function player_test:new(...)
  local p = opencrypt.Entity.new(self, ...)

  setmetatable(p, self.metatable)
  table.insert(instances, p)
  return p
end

function player_test.setMoveEvent(e, x,y)
  e.addListener(function(pressed)
    if pressed then
      for _,p in ipairs(instances) do
        p:move(x,y)
      end
    end
  end)
end

return player_test

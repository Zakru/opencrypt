local Type = {}
Type.metatable = {__index = Type}

function Type:new()
  local t = {}

  setmetatable(t, self.metatable)
  return t
end

function Type:newChild()
  local child = {}
  child.metatable = {__index = child}

  setmetatable(child, self.metatable)
  return child
end

function Type:instanceOf(type)
  local mt = getmetatable(self)
  while mt and mt.__index do
    if mt.__index == type then
      return true
    end

    mt = getmetatable(mt.__index)
  end

  return false
end

return Type
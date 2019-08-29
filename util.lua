_G.iter = function(t)
  if t == nil then return function() return nil end end
  local i = 0
  return function()
    i = i + 1
    return t[i]
  end
end

function table.count(t, func)
  local count = 0
  local function increment(...)
    if func(...) then
      count = count + 1
    end
  end
  table.foreach(t, increment)
  return count
end

function table.some(t, func)
  for v in iter(t) do
    if func(v) then
      return true
    end
  end
  return false
end

function table.all(t, func)
  for v in iter(t) do
    if not func(v) then
      return false
    end
  end
  return true
end

function table.filter(t, func)
  local t2 = {}
  for i=1,#t do
    if func(t[i]) then
      table.insert(t2, t[i])
    end
  end
  return t2
end

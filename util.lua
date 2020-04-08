[[
Copyright 2019 Zakru

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

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

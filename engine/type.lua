--[[
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
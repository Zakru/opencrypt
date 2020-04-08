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

function Mod:draw()
end

return Mod

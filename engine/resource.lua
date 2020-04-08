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

local Type = require('engine/type')

local Resource = Type:newChild()

function Resource:new(path)
  local r = Type.new(self)

  r.path = path
  r.type = self:getType(path)

  return r
end

function Resource:getType(path)
  if path:match('%.str%.ogg$') then
    return 'audio_stream'
  elseif path:match('%.ogg$') then
    return 'audio'
  else
    return 'text'
  end
end

function Resource:getInstance()
  if self.type == 'audio' then
    return love.audio.newSource(self.path, 'static')
  elseif self.type == 'audio_stream' then
    return love.audio.newSource(self.path, 'stream')
  elseif self.type == 'text' then
    local contents, size = love.filesystem.read(self.path)
    return contents
  end
end

return Resource

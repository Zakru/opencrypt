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
  end
end

function Resource:getInstance()
  if self.type == 'audio' then
    return love.audio.newSource(self.path, 'static')
  elseif self.type == 'audio_stream' then
    return love.audio.newSource(self.path, 'stream')
  end
end

return Resource

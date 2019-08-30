local JSON = require('JSON')

-- AnimationCondition

local AnimationCondition = opencrypt.Type:newChild()

function AnimationCondition:new(field, operator, value)
  local ac = opencrypt.Type.new(self)

  ac.field = field
  ac.operator = operator
  ac.value = value

  return ac
end

function AnimationCondition:entityFulfills(entity)
  local v = entity[self.field]
  if self.operator == '==' then
    return v == self.value
  elseif self.operator == '!=' or self.operator == '~=' then
    return v ~= self.value
  elseif self.operator == '<' then
    return v < self.value
  elseif self.operator == '>' then
    return v > self.value
  elseif self.operator == '<=' then
    return v <= self.value
  elseif self.operator == '>=' then
    return v >= self.value
  end

  return false
end

-- AnimationTrack

local AnimationTrack = opencrypt.Type:newChild()

function AnimationTrack:new(times, frames, conditions)
  local at = opencrypt.Type.new(self)

  at.times = times
  at.frames = frames
  at.conditions = conditions

  return at
end

function AnimationTrack:canPlay(ent)
  for c in iter(conditions) do
    if not c:entityFulfills(c) then return false end
  end
  return true
end

local Animator = opencrypt.Type:newChild()

function Animator:new(tracks, xframes,yframes, fullw,fullh)
  local a = opencrypt.Type.new(self)

  a.tracks = tracks
  a.xframes = xframes
  a.yframes = yframes

  local w = fullw / xframes
  local h = fullh / yframes
  a.quads = {}
  local i = 1
  for t=1,yframes do
    for f=1,xframes do
      a.quads[i] = love.graphics.newQuad((f-1) * w, (t-1) * h, w,h, fullw,fullh)
      i = i + 1
    end
  end

  return a
end

function Animator:getCurrentQuad(entity)
  local progress = self.music:progressToNextBeat()
  for track in iter(self.tracks) do
    if track:canPlay(entity) then
      for t,time in ipairs(track.times) do
        if progress < time then
          return track.frames[t]
        end
      end
      return track.frames[1]
    end
  end
  return 1
end

function Animator:draw(graphics, entity, x,y, flip)
  local sx = 1
  if flip then
    sx = -1
  end
  local xoff = entity.texture:getWidth()/2/self.xframes
  graphics.draw(entity.texture, self.quads[self:getCurrentQuad(entity)], xoff+x,y, 0, sx,1, xoff)
end

function Animator:fromJSON(json)
  local data = JSON:decode(json)

  if data then
    if data.tracks and data.xFrames and data.yFrames and data.texWidth and data.texHeight then
      local tracks = {}

      for track in iter(data.tracks) do
        local times = track.times
        local frames = track.frames
        local conditions

        if track.conditions then
          conditions = {}
          for condition in iter(track.conditions) do
            conditions[#conditions+1] = AnimationCondition:new(condition.field, condition.operator, condition.value)
          end
        end

        tracks[#tracks+1] = AnimationTrack:new(times, frames, conditions)
      end

      return Animator:new(tracks, data.xFrames,data.yFrames, data.texWidth,data.texHeight)
    end
  end

  error('Invalid animator data')
end

local animators = {Animator=Animator, AnimationTrack=AnimationTrack, AnimationCondition=AnimationCondition}
return animators

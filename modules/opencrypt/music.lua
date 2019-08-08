local entity = require('entity')

local Music = opencrypt.Type:newChild()

function Music:new(audio, beats)
  local m = opencrypt.Type.new(self)

  m.audio = audio
  m.beatIndex = 1
  m.beats = beats or {}

  return m
end

function Music:start()
  if self.instance then
    self.instance:stop()
    self.instance:release()
  end
  self.instance = self.audio:getInstance()
  self.instance:play()
end

function Music:stop()
  if self.instance then
    self.instance:stop()
  end
  self.beatIndex = 1
end

function Music:progressToNextBeat()
  if self.beatIndex == #self.beats + 1 then
    return 0
  end

  local previous = self.beats[self.beatIndex-1] or 0
  local next = self.beats[self.beatIndex]
  local timeToNext = next - self.instance:tell()
  if timeToNext <= 0 then
    self.beatIndex = self.beatIndex + 1
    return self:progressToNextBeat()
  end
  local beatDuration = next - previous
  return 1 - (timeToNext / beatDuration)
end

function Music:generateBeats(offset, interval, count)
  for i=1,count do
    local pos = offset + (i-1) * interval
    table.insert(self.beats, pos)
  end
end

local MusicWorld = opencrypt.World:newChild()

function MusicWorld:new(music, ...)
  local mw = opencrypt.World.new(self, ...)

  mw.music = music

  return mw
end

function MusicWorld:begin()
  opencrypt.World.begin(self)

  self.music:start()
end

function MusicWorld:endWorld()
  if self.music then
    self.music:stop()
  end

  opencrypt.World.endWorld(self)
end

music = {Music=Music, MusicWorld=MusicWorld}
return music

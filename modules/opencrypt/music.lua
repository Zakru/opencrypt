local Music = {}
Music.metatable = {__index = Music}

function Music:new(source, beats)
  local m = {}

  m.source = source
  m.beatIndex = 1
  m.beats = beats or {}

  setmetatable(m, self.metatable)
  return m
end

function Music:progressToNextBeat()
  if self.beatIndex == #self.beats + 1 then
    return 0
  end

  local previous = self.beats[self.beatIndex-1] or 0
  local next = self.beats[self.beatIndex]
  local timeToNext = next - self.source:tell()
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
  print(#self.beats)
  print(self.beats[1])
  print(self.beats[2])
end

music = {Music=Music}
return music

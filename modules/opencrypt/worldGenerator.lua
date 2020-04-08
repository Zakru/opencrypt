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

local music = selfRequire('music')

math.randomseed(os.time()); math.random(); math.random(); math.random();

-- Called when a world this handler is assigned to ends
local function onWorldEnd(world)
  -- Reset player_test's last beat
  player_test.lastBeat = 0
end

-- Prepare the world generator
local worldGenerator = {}

function worldGenerator:attemptRoom(map, x,y, w,h)
  -- Test if overlapping
  for x1=x-1,x+w do
    for y1=y-1,y+h do
      if map:getTileAt(x1,y1) == self.floor then
        return false
      end
    end
  end

  -- Test if another room nearby
  local roomNearby = false
  for x1=x,x+w-1 do
    for y1=y-5,y+h+4 do
      if map:getTileAt(x1,y1) == self.floor then
        roomNearby = true
        break
      end
    end
    if roomNearby then break end
  end

  if not roomNearby then
    for x1=x-5,x+w+4 do
      for y1=y,y+h-1 do
        if map:getTileAt(x1,y1) == self.floor then
          roomNearby = true
          break
        end
      end
      if roomNearby then break end
    end
  end

  if not roomNearby then
    return false
  end

  -- Actually generate room
  for x1=x-1,x+w do
    for y1=y-1,y+h do
      if x1 == x-1 or x1 == x+w or y1 == y-1 or y1 == y+h then
        map:setTileAt(x1,y1, self.wall)
      else
        map:setTileAt(x1,y1, self.floor)
      end
    end
  end

  local edges = 2 * (w + h)

  while true do
    local i = math.random(edges)
    local x1,y1
    local dx,dy
    if i > 2*w+h then
      x1 = x
      y1 = y+2*w+2*h-i
      dx = -1
      dy = 0
    elseif i > w+h then
      x1 = x+2*w+h-i
      y1 = y+h-1
      dx = 0
      dy = 1
    elseif i > w then
      x1 = x+w-1
      y1 = y+i-w-1
      dx = 1
      dy = 0
    else
      x1 = x+i-1
      y1 = y
      dx = 0
      dy = -1
    end
    local valid = false
    local x2 = x1
    local y2 = y1
    for _=1,5 do
      x2 = x2 + dx
      y2 = y2 + dy
      if map:getTileAt(x2,y2) == self.floor then
        valid = true
        break
      end
    end

    if valid then
      local x2 = x1
      local y2 = y1
      for _=1,5 do
        x2 = x2 + dx
        y2 = y2 + dy
        if map:getTileAt(x2,y2) == self.floor then
          return true
        end
        map:setTileAt(x2,y2, self.floor)
      end
    end
  end
end

-- Generate the next world from this generator
function worldGenerator:nextWorld()
  -- Create a tilemap
  local t = opencrypt.Tilemap:new(32, 32)

  -- Fill the tilemap
  for x=1,32 do
    for y=1,32 do
      t:setTileAt(x,y, self.wall)
    end
  end

  -- Start room
  for x=13,19 do
    for y=13,19 do
      if x == 13 or x == 19 or y == 13 or y == 19 then
        t:setTileAt(x,y, self.wall)
      else
        t:setTileAt(x,y, self.floor)
      end
    end
  end

  -- Generate some rooms
  local count = 0
  while count < 8 do
    local w = math.random(5,7)
    local h = math.random(4,6)
    if self:attemptRoom(t, math.random(2,32-w), math.random(2,32-h), w,h) then
      count = count + 1
    end
  end

  world = music.MusicWorld:new(self.music, t, 24)

  -- Spawn player
  local player = self.player:new(world, 16,16)
  world:spawn(player)

  -- Set the world to track the player's camera entity
  world.track = player.camera

  -- Set the world's end listener to the function defined above
  world:addOnEndListener(onWorldEnd)
  world.nextGenerator = self
  return world
end

return worldGenerator

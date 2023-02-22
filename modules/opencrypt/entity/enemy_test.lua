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

local entity = selfRequire('entity')
local enemy_test = entity.JumpCreature:newChild(3)
local instances = {}
enemy_test.jumpHeight = 0.5
enemy_test.nextMoveNext = false

function enemy_test:new(...)
  local e = entity.JumpCreature.new(self, ...)

  e.moveNext = enemy_test.nextMoveNext
  enemy_test.nextMoveNext = not enemy_test.nextMoveNext
  e.direction = 'right'

  setmetatable(e, self.metatable)
  table.insert(instances, e)
  return e
end

function enemy_test.directionVector(dir)
  if dir == 'right' then
    return 1,0
  elseif dir == 'left' then
    return -1,0
  elseif dir == 'down' then
    return 0,1
  elseif dir == 'up' then
    return 0,-1
  end
  return 0,0
end

function enemy_test:draw(graphics)
  entity.JumpCreature.draw(self, graphics)
  local x,y = self:getVisualOrigin(graphics)
  graphics.print(tostring(self.health), x+12, y+12)
end

function enemy_test:move()
  local x,y = enemy_test.directionVector(self.direction)
  return entity.JumpCreature.move(self, x,y)
end

function enemy_test:chooseDirection(disregardEntities)
  if self.target then
    local xDiff = self.target.x - self.x
    local yDiff = self.target.y - self.y

    function walkable(x,y)
      local tile = self.world.tilemap:getTileAt(self.x + x, self.y + y)
      local e = disregardEntities or table.all(self.world:getEntitiesAt(self.x + x, self.y + y), function(v)
        return v == self.target or v:isWalkable()
      end)
      return tile and tile:isWalkable() and e
    end

    function choose()
      if math.abs(yDiff) > math.abs(xDiff) then
        if yDiff > 0 then
          self.direction = 'down'
          if walkable(0,1) then
            return
          end
        else
          self.direction = 'up'
          if walkable(0,-1) then
            return
          end
        end

        if xDiff > 0 then
          self.direction = 'right'
        elseif xDiff < 0 then
          self.direction = 'left'
        end
      else
        if xDiff > 0 then
          self.direction = 'right'
          if walkable(1,0) then
            return
          end
        else
          self.direction = 'left'
          if walkable(-1,0) then
            return
          end
        end

        if yDiff > 0 then
          self.direction = 'down'
        elseif yDiff < 0 then
          self.direction = 'up'
        end
      end
    end

    local nw = not walkable(enemy_test.directionVector(self.direction))
    if nw or
      (self.direction == 'right' and xDiff <= 0) or
      (self.direction == 'left' and xDiff >= 0) or
      (self.direction == 'down' and yDiff <= 0) or
      (self.direction == 'up' and yDiff >= 0)
    then
      choose()
    end
  end
end

function enemy_test:step(world)
  if self.moveNext then
    local x,y = enemy_test.directionVector(self.direction)
    local e = self.world:getFirstEntityAt(self.x + x, self.y + y)
    if e and not e:isWalkable() then
      e:callStep(world)
      local e = self.world:getFirstEntityAt(self.x + x, self.y + y)
      if e and not e:isWalkable() then
        self:chooseDirection(false)
      end
    else
      self:chooseDirection(true)
    end
    if self:move() then
      self.moveNext = false
    end
  else
    self:chooseDirection(true)
    self.moveNext = true
  end
end

function enemy_test:setTarget(t)
  self.target = t
end

function enemy_test:getDamage()
  return 1
end

function enemy_test:willAttack(ent)
  return ent == self.target
end

function enemy_test:destroy()
  for i,inst in ipairs(instances) do
    if inst == self then
      table.remove(instances, i)
      return
    end
  end
end

return enemy_test

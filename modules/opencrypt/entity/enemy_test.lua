local enemy_test = opencrypt.Creature:newChild(3)
local instances = {}
enemy_test.nextMoveNext = false

function enemy_test:new(...)
  local e = opencrypt.Creature.new(self, ...)

  e.moveNext = enemy_test.nextMoveNext
  enemy_test.nextMoveNext = not enemy_test.nextMoveNext
  e.direction = 'right'

  setmetatable(e, self.metatable)
  table.insert(instances, e)
  return e
end

function enemy_test.giveStepEvent(event)
  event.addListener(function ()
    for _,e in ipairs(instances) do
      e:ai()
    end
  end)
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

function enemy_test:draw(graphics, x,y)
  opencrypt.Creature.draw(self, graphics, x,y)
  graphics.print(tostring(self.health), x+12, y+12)
end

function enemy_test:move()
  local x,y = enemy_test.directionVector(self.direction)
  return opencrypt.Creature.move(self, x,y)
end

function enemy_test:chooseDirection()
  if self.target then
    local xDiff = self.target.x - self.x
    local yDiff = self.target.y - self.y
    
    function walkable(x,y)
      local tile = self.world.tilemap:getTileAt(self.x + x, self.y + y)
      local e = table.all(self.world:getEntitiesAt(self.x + x, self.y + y), function(v)
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

function enemy_test:ai()
  self:chooseDirection()
  if self.moveNext then
    if self:move() then
      self.moveNext = false
    end
  else
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

return enemy_test

local stairs_down = opencrypt.Tile:new()
stairs_down.playerMeta = nil

function stairs_down:onWalkInto(world, x,y, ent)
  if getmetatable(ent) == stairs_down.playerMeta then
    self:onEnter()
  end
end

function stairs_down:onEnter()
end

return stairs_down

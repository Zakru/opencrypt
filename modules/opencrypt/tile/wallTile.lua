local WallTile = opencrypt.Tile:newChild()
WallTile.layer = 2

function WallTile:draw(graphics, x,y)
  graphics.draw(self.texture, x*graphics.tileSize,y*graphics.tileSize-15)
end

function WallTile:isWalkable()
  return false
end

return WallTile

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

-- A RenderEngine holds a world which it can render and controls the rendering process
-- It can also contain UIRenderers for UI rendering
local RenderEngine = {}
RenderEngine.metatable = {__index = RenderEngine}

function RenderEngine.new()
  local re = {}

  re.uiRenderers = {}

  setmetatable(re, RenderEngine.metatable)
  return re
end

local function wrappedGraphics(xoff,yoff, tileSize)
  local wg = {}
  wg.tileSize = tileSize

  local function draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
    x = xoff + x
    y = yoff + y
    love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy, kx, ky)
  end

  local function drawQuad(texture, quad, x, y, r, sx, sy, ox, oy, kx, ky)
    x = xoff + x
    y = yoff + y
    love.graphics.draw(texture, quad, x, y, r, sx, sy, ox, oy, kx, ky)
  end

  function wg.draw(...)
    if type(({...})[2]) == 'number' then
      return draw(...)
    end
    return drawQuad(...)
  end

  function wg.print(text, x, y, r, sx, sy, ox, oy, kx, ky)
    x = xoff + x
    y = yoff + y
    return love.graphics.print(text, x, y, r, sx, sy, ox, oy, kx, ky)
  end

  return wg
end

function RenderEngine:render()
  if #self.uiRenderers == 0 and self.world == nil then
    -- Nothing to render
    return
  end

  -- Prepare rendering by setting general state. This should be reset if changed.
  local mul = 2
  love.graphics.scale(mul,mul) -- This should be calculated from resolution in the future

  if self.world then
    local xoff, yoff = 0,0
    if self.world.track then
      xoff, yoff = love.graphics.getWidth() / 2 / mul - (self.world.track.x - 0.5) * self.world.scale, love.graphics.getHeight() / 2 / mul - (self.world.track.y - 0.5) * self.world.scale
    end

    -- Render layer 1
    self.world:forTileRows(function(row, y)
      self.world:forTilesInRow(row, function(tile, x)
        if tile.layer == 1 then
          tile:draw(wrappedGraphics(xoff,yoff, self.world.scale), x-1, y-1)
        end
      end)
    end)

    -- Render layer 2 and entities
    self.world:forTileRows(function(row, y)
      self.world:forTilesInRow(row, function(tile, x)
        if tile.layer == 2 then
          tile:draw(wrappedGraphics(xoff,yoff, self.world.scale), x-1, y-1)
        end
      end)

      self.world:forEntitiesOnRow(y, function(ent)
        ent:draw(wrappedGraphics(xoff,yoff, self.world.scale))
      end)
    end)

    -- Render layer 3
    self.world:forTileRows(function(row, y)
      self.world:forTilesInRow(row, function(tile, x)
        if tile.layer == 3 then
          tile:draw(wrappedGraphics(xoff,yoff, self.world.scale), x-1, y-1)
        end
      end)
    end)
  end
end

return RenderEngine

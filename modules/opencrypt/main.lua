local opencryptMod = opencrypt.Mod.new()

function opencryptMod:load(registry)
  registry.registerEventListener('')
end

function opencryptMod:postLoad(registered)
  self.registered = registered
end

function opencryptMod:getInitialWorld()
  local t = opencrypt.Tilemap.new(10, 10)
  for x=1,10 do
    for y=1,10 do
      if x == 1 or x == 10 or y == 1 or y == 10 then
        t:setTileAt(x,y, self.registered.tiles.wall_test)
      else
        t:setTileAt(x,y, self.registered.tiles.floor_test)
      end
    end
  end
  return opencrypt.World.new(
    t,
    {self.registered.entities.player_test.new(5,5)},
    {},
    24
  )
end

return opencryptMod

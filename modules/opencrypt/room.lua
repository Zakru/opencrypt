local BBox = opencrypt.Type:newChild()

function BBox:new(x,y, w,h)
  local bb = opencrypt.Type.new(self)

  bb.x = x
  bb.y = y
  bb.w = w
  bb.h = h

  return bb
end

function BBox:overlaps(other)
  return (
    self.x < other.x + other.w and
    other.x < self.x + self.w and
    self.y < other.y + other.h and
    other.y < self.y + self.h
  )
end

local Room = opencrypt.Type:newChild()

function Room:bake(world)
end

function Room:getBBoxes()
  return {}
end

function Room:overlaps(other)
  for own in iter(self:getBBoxes()) do
    for their in iter(other:getBBoxes()) do
      if own:overlaps(their) then return true end
    end
  end

  return false
end

function Room:bboxOverlaps(bbox)
  for own in iter(self:getBBoxes()) do
    if own:overlaps(bbox) then return true end
  end

  return false
end

local Corridor = Room:newChild()

function PlainRoom:new(x,y, w,h, depth)

local PlainRoom = Room:newChild()

function PlainRoom:new(set, x,y, w,h, connectTo)
  local mainBBox = BBox:new(x-1,y-1, w+2,h+2)
  local depth
  for room in iter(set) do
    if room:bboxOverlaps(mainBBox) then
      if connectTo == nil or room.depth == connectTo then
        depth = room.depth + 1
      end
    end
  end
  local r = opencrypt.Type.new(self)

  r.x = x
  r.y = y
  r.w = w
  r.h = h
  r.depth = depth

  r.bboxes = {
    mainBBox
  }



  return r
end

function PlainRoom:getBBoxes()
  return self.bboxes
end

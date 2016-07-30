require("libraries/util")

Queue = class(
  {},
  {
      __class__name = "Queue"
  }
)

function Queue:constructor()
  self.first = 0
  self.last = -1
end

function Queue:PushLeft(value)
  local first = self.first - 1
  self.first = first
  self[first] = value
end

function Queue:PushRight(value)
  local last = self.last + 1
  self.last = last
  self[last] = value
end

function Queue:PopLeft()
  local first = self.first
  if first > self.last then error("Queue is empty") end
  local value = self[first]
  self[first] = nil        -- to allow garbage collection
  self.first = first + 1
  return value
end

function Queue:PopRight()
  local last = self.last
  if self.first > last then error("Queue is empty") end
  local value = self[last]
  self[last] = nil         -- to allow garbage collection
  self.last = last - 1
  return value
end

print( "queue.lua is loaded." )
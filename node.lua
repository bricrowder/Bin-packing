node = {}
node.__index = node

function node.new(x, y, w, h)
    local n = {}
    setmetatable(n, node)

    -- location/size info about the node
    n.x = x
    n.y = y
    n.w = w
    n.h = h

    -- if the node has a rectangle in it
    n.used = false

    -- reference to right/down nodes
    n.right = nil
    n.down = nil

    return n
end

return node
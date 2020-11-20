binarytree = {}
binarytree.__index = binarytree

function binarytree.new(w, h)
    local b = {}
    setmetatable(b, binarytree)

    -- create the first node
    b.root = node.new(0, 0, w, h)

    return b
end

function binarytree:fit(b)
    -- loop through the list of rectangles
    for i, v in ipairs(b) do
        -- find the first available space, starting at the root node
        local n = self:find(self.root, v.w, v.h)
        if n then
            -- if we found a node, assign it to the rectable object and split the remaining space
            v.node = self:split(n, v.w, v.h)
        end
    end
end

function binarytree:find(n, w, h)
    if n.used then
        -- node is already used, search in the right/down nodes
        return self:find(n.right, w, h) or self:find(n.down, w, h)
    elseif w <= n.w and h <= n.h then
        -- not used, check if it would fit
        return n
    end
    -- neither are true, return false
    return nil
end

function binarytree:split(n, w, h)
    -- mark the node as used
    n.used = true
    -- create right/down nodes based on the size of the node and w/h of the rectangle
    n.right = node.new(n.x + w, n.y, n.w - w, h) 
    n.down = node.new(n.x, n.y + h, n.w, n.h - h)
    return n
end

return binarytree
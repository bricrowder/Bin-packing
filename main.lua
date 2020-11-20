binarytree = require "binarytree"
node = require "node"

function love.load()
    -- Camera Object
    camera = {}
    camera.scale = 2

    container = {w=256, h=256}

    blocks = {
        {id=1, w=128, h=64},
        {id=2, w=64, h=32},
        {id=3, w=64, h=64},
        {id=4, w=32, h=32},
        {id=5, w=32, h=32},
        {id=6, w=32, h=32},
        {id=7, w=16, h=16},
        {id=8, w=16, h=16},
        {id=9, w=16, h=16}
    }

    -- tree of sprites with a starting container width of 256x256
    bt = binarytree.new(container.w, container.h)

    bt:fit(blocks)

end

function love.update(dt)

end

function love.keypressed(key)
    if key == "space" then
        
    end
end

function love.draw()
    -- start scaled drawing
    love.graphics.push()
    love.graphics.scale(camera.scale)

    love.graphics.setColor(0,255,0,255)
    love.graphics.rectangle("line", 0, 0, container.w, container.h)


    for i, v in ipairs(blocks) do
    love.graphics.setColor(0,128,128,255)
        if v.node then
            love.graphics.rectangle("line", v.node.x, v.node.y, v.w, v.h)
            love.graphics.print(v.id, v.node.x, v.node.y)
        end
    end

    -- done with camera drawing
    love.graphics.pop()

    -- draw non scaled drawing

end

-- loads sprite s into the sprites list, returns the index of the added sprite
function addSprite(originaldata)

    -- get left bounds
    local left = 0
    for x=1, originaldata:getWidth(), 1 do
        local breakfor = false
        for y=1, originaldata:getHeight(), 1 do
            local r, g, b, a = originaldata:getPixel(x-1, y-1)
            if a > 1 then
                left = x-1
                breakfor = true
                break
            end
        end
        if breakfor then
            break
        end
    end

    -- get right bounds
    local right = originaldata:getWidth()-1
    for x=originaldata:getWidth(), 1, -1 do
        local breakfor = false
        for y=1, originaldata:getHeight(), 1 do
            local r, g, b, a = originaldata:getPixel(x-1, y-1)
            if a > 1 then
                right = x-1
                breakfor = true
                break
            end
        end
        if breakfor then
            break
        end            
    end

    -- get top bounds
    local top = 0
    for y=1, originaldata:getHeight(), 1 do
        local breakfor = false
        for x=1, originaldata:getWidth(), 1 do
            local r, g, b, a = originaldata:getPixel(x-1, y-1)
            if a > 1 then
                top = y-1
                breakfor = true
                break
            end
        end
        if breakfor then
            break
        end            
    end

    -- get bottom bounds
    local bottom = originaldata:getHeight()-1
    for y=originaldata:getHeight(), 1, -1 do
        local breakfor = false
        for x=1, originaldata:getWidth(), 1 do
            local r, g, b, a = originaldata:getPixel(x-1, y-1)
            if a > 1 then
                bottom = y-1
                breakfor = true
                break
            end
        end
        if breakfor then
            break
        end            
    end

    -- setup trimed image
    local trimmedw = right - left + 1
    local trimmedh = bottom - top + 1
    local trimmeddata = love.image.newImageData(trimmedw, trimmedh)
    trimmeddata:paste(originaldata, 0, 0, top, left, trimmedw, trimmedh)

    -- setup extruded image
    local extrudedw = trimmedw + 2
    local extrudedh = trimmedh + 2
    local extrudeddata = love.image.newImageData(extrudedw, extrudedh)
    extrudeddata:paste(originaldata, 1, 1, top, left, trimmedw, trimmedh)

    -- setup image with only extrusions
    local extrusionsdata = love.image.newImageData(extrudedw, extrudedh)
    
    -- left & right extrusions
    for y=1, extrudedh, 1 do
        extrudeddata:setPixel(0, y-1, extrudeddata:getPixel(1, y-1))
        extrudeddata:setPixel(extrudedw-1, y-1, extrudeddata:getPixel(extrudedw-2, y-1))
        extrusionsdata:setPixel(0, y-1, extrudeddata:getPixel(1, y-1))
        extrusionsdata:setPixel(extrudedw-1, y-1, extrudeddata:getPixel(extrudedw-2, y-1))
    end

    -- top & bottom extrusions
    for x=1, extrudedw, 1 do
        extrudeddata:setPixel(x-1, 0, extrudeddata:getPixel(x-1, 1))
        extrudeddata:setPixel(x-1, extrudedh-1, extrudeddata:getPixel(x-1, extrudedh-2))
        extrusionsdata:setPixel(x-1, 0, extrudeddata:getPixel(x-1, 1))
        extrusionsdata:setPixel(x-1, extrudedh-1, extrudeddata:getPixel(x-1, extrudedh-2))
    end

    table.insert(sprites, {original=love.graphics.newImage(originaldata), trimmed=love.graphics.newImage(trimmeddata), extruded=love.graphics.newImage(extrudeddata), extrusions=love.graphics.newImage(extrusionsdata)})

    return #sprites
end

-- removes a sprite from the list
function removeSprite(i)
    table.remove(sprites, i)
end

-- handles a file drop event
function love.filedropped(f)
    -- open the file and create the image object
    if f:open("r") then
        -- load image data
        addSprite(love.image.newImageData(love.filesystem.newFileData(f:read(), f:getFilename())))
        f:close()
    end
end

-- handles a directory drop event
function love.directorydropped(d)
    -- mount the directory
    if love.filesystem.mount(d, "import") then 
        -- get all the files in the folder
        local files = love.filesystem.getDirectoryItems("import")

        -- loop through all the entries
        for i, v in ipairs(files) do
            -- only process if it is a file
            if love.filesystem.isFile("import/" .. v) then
                local f = love.filesystem.newFile("import/" .. v)
                -- open and add the sprite
                if f:open("r") then
                    addSprite(love.image.newImageData(love.filesystem.newFileData(f:read(), f:getFilename())))
                    f:close()
                end
            end
        end

        -- unmount the directory
        love.filesystem.unmount(d)        
    end
end

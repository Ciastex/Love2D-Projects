function love.load()
    require("framework")
    require("simulation.Body")
    require("simulation.Cell")
    
    math.randomseed(os.time())
    
    body = Body(128, 128, 4)
    body:createCell(math.random(1, 128), math.random(1, 128))
end

function love.update(dt)
    body:update(dt)
end

function love.draw()
    body:draw()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "space" then
        body = Body(128, 128, 1)
        body:createCell(math.random(1, 128), math.random(1, 128))
    end
end
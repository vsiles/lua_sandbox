vector = require "vector"

level = {}
player = {}
camera = vector.new(0, 0)
nr_cells = 0

IDLE, LEFT, RIGHT, JUMP = 0, 1, 2, 3

function love.load()
    -- level info
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()


    nr_cells = width / 32
    local nh = math.floor(height / 32) - 5
    for i = 0 , nr_cells - 1 do
        level[i] = {}
        level[i].pos = vector.new(i, nh)
        level[i].size = vector.new(1, 1)
    end

    -- player info
    player.pos = vector.new(love.graphics.getWidth() / 2, 32 * (nh - 1))

    player.img = {}
    player.img[IDLE] = love.graphics.newImage('gfx/purple.png')
    player.img[LEFT] = love.graphics.newImage('gfx/left32.png')
    player.img[RIGHT] = love.graphics.newImage('gfx/right32.png')
    player.img[JUMP] = love.graphics.newImage('gfx/up32.png')
    player.state = IDLE

    player.speed = 200
    player.ground = player.pos.y -- This makes the character land on the plaform.

    player.y_velocity = 0        -- Whenever the character hasn't jumped yet, the Y-Axis velocity is always at 0.

    player.jump_height = -300    -- Whenever the character jumps, he can reach this height.
    player.gravity = -500        -- Whenever the character falls, he will descend at this rate.
end

function love.update(dt)
    local img = player.img[player.state]

    if love.keyboard.isDown('escape') then
        love.event.quit()
    end

    if love.keyboard.isDown('left') then
        camera.x = camera.x - 32
    end
    
    if love.keyboard.isDown('right') then
        camera.x = camera.x + 32
    end

    if love.keyboard.isDown('d') then
        player.state = RIGHT
        if player.pos.x < (love.graphics.getWidth() - img:getWidth()) then
            player.pos.x = player.pos.x + (player.speed * dt)
        end
    elseif love.keyboard.isDown('q') then
        player.state = LEFT
        if player.pos.x > 0 then
            player.pos.x = player.pos.x - (player.speed * dt)
        end
    else
        player.state = IDLE
    end

    if love.keyboard.isDown('z') then
        if player.y_velocity == 0 then
            player.y_velocity = player.jump_height
        end
    end

    if player.y_velocity ~= 0 then
        if player.state == IDLE then
            player.state = JUMP
        end
        player.pos.y = player.pos.y + player.y_velocity * dt
        player.y_velocity = player.y_velocity - player.gravity * dt
    end

    if player.pos.y > player.ground then
        player.y_velocity = 0
        player.pos.y = player.ground
    end
end

function love.draw()
    love.graphics.setColor(255, 255, 255)
    -- draw background grid
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local nw = nr_cells
    local nh = height / 32

    for i = 0, nw - 1 do
        -- TODO: read doc -> line
        love.graphics.rectangle('fill', 32 * i, 0, 1, height) 
    end
    for i = 0, nh - 1 do
        -- TODO: read doc -> line
        love.graphics.rectangle('fill', 0, 32 * i, width, 1)
    end

    -- display some info
    love.graphics.print(string.format("Y velocity = %d", player.y_velocity))
    love.graphics.print(string.format("Player pos = %d, %d", player.pos.x, player.pos.y),
                        0, 20)
    
    love.graphics.push()
    love.graphics.translate(-camera.x, -camera.y)

    for i = 0, nr_cells - 1 do
        local ci = i * 255 / 32
        love.graphics.setColor(ci, 255 - ci, (255 - ci) / 2)
        love.graphics.rectangle('fill', 32 * level[i].pos.x, 32 * level[i].pos.y,
                                32 * level[i].size.x, 32 * level[i].size.y)
    end

    -- drawable, x, y, rotation (rad), scale x, scale y, origin offset x, origin offset y
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(player.img[player.state], player.pos.x, player.pos.y,
                       0, 1, 1, 0, 0)

    love.graphics.pop()
end

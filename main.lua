platform = {}
player = {}

IDLE, LEFT, RIGHT, JUMP = 0, 1, 2, 3

function love.load()
    -- level info
    platform.width = love.graphics.getWidth()
    platform.height = love.graphics.getHeight() / 2

    platform.x = 0
    platform.y = platform.height

    -- player info
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2

    player.img = {}
    player.img[IDLE] = love.graphics.newImage('gfx/purple.png')
    player.img[LEFT] = love.graphics.newImage('gfx/left32.png')
    player.img[RIGHT] = love.graphics.newImage('gfx/right32.png')
    player.img[JUMP] = love.graphics.newImage('gfx/up32.png')
    player.pos = IDLE

    player.speed = 200
    player.ground = player.y     -- This makes the character land on the plaform.

    player.y_velocity = 0        -- Whenever the character hasn't jumped yet, the Y-Axis velocity is always at 0.

    player.jump_height = -300    -- Whenever the character jumps, he can reach this height.
    player.gravity = -500        -- Whenever the character falls, he will descend at this rate.
end

function love.update(dt)
    local img = player.img[player.pos]
    if love.keyboard.isDown('d') then
        player.pos = RIGHT
        if player.x < (love.graphics.getWidth() - img:getWidth()) then
            player.x = player.x + (player.speed * dt)
        end
    elseif love.keyboard.isDown('q') then
        player.pos = LEFT
        if player.x > 0 then
            player.x = player.x - (player.speed * dt)
        end
    else
        player.pos = IDLE
    end

    if love.keyboard.isDown('z') then
        if player.y_velocity == 0 then
            player.y_velocity = player.jump_height
        end
    end

    if player.y_velocity ~= 0 then
        if player.pos == IDLE then
            player.pos = JUMP
        end
        player.y = player.y + player.y_velocity * dt
        player.y_velocity = player.y_velocity - player.gravity * dt
    end

    if player.y > player.ground then
        player.y_velocity = 0
        player.y = player.ground
    end
end

function love.draw()
    love.graphics.setColor(255, 255, 255)

    love.graphics.rectangle('fill', platform.x, platform.y, platform.width,
                            platform.height)

    -- drawable, x, y, rotation (rad), scale x, scale y, origin offset x, origin offset y
    love.graphics.draw(player.img[player.pos], player.x, player.y, 0, 1, 1, 0, 32)
end

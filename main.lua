vector = require "vector"

level = {}
player = {}
camera = vector.new(0, 0)
nr_cells = 0
nr_lines = 0

IDLE, LEFT, RIGHT, JUMP = 0, 1, 2, 3

function pos2cell(x, y)
    local i = x / 32
    local j = y / 32
    return vector.new(math.floor(i), math.floor(j))
end

function love.load()

    -- level info
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()


    local nr_cells_plat = width / 32
    nr_lines = nr_cells_plat
    nr_cells = nr_cells_plat + 2
    local nh = math.floor(height / 32) - 5
    for i = 0 , nr_cells_plat - 1 do
        level[i] = {}
        level[i].pos = vector.new(i, nh)
        level[i].size = vector.new(1, 1)
    end

    level[nr_cells_plat] = {}
    level[nr_cells_plat].pos = vector.new(10, nh - 2)
    level[nr_cells_plat].size = vector.new(1, 1)

    level[nr_cells_plat + 1] = {}
    level[nr_cells_plat + 1].pos = vector.new(11, nh - 2)
    level[nr_cells_plat + 1].size = vector.new(1, 1)

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
        camera.x = camera.x - 10
    end
    
    if love.keyboard.isDown('right') then
        camera.x = camera.x + 10
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

function collision(player, cell)
    local phalfsize = 16
    local pcenter = player.pos.x + phalfsize

    local chalfsize = 16 * cell.size.x
    local ccenter = 32 * cell.pos.x + chalfsize

    local dist1 = math.abs(pcenter - ccenter)
    local dist2 = phalfsize + chalfsize
    if dist1 >= dist2 then
        return false
    end

    phalfsize = 16
    pcenter = player.pos.y + phalfsize

    chalfsize = 16 * cell.size.y
    ccenter = 32 * cell.pos.y + chalfsize

    dist1 = math.abs(pcenter - ccenter)
    dist2 = phalfsize + chalfsize
    if dist1 >= dist2 then
        return false
    end

    return true
end

function love.draw()
    love.graphics.setColor(255, 255, 255)

    local p1x = camera.x % 32
    local p1y = camera.y % 32
    local p2x = camera.x - p1x
    local p2y = camera.y - p1y

    -- display some info
    love.graphics.print(string.format("Y velocity = %d", player.y_velocity), 10, 10)
    love.graphics.print(string.format("Player pos = %d, %d", player.pos.x, player.pos.y),
                        10, 40)
    
    love.graphics.push()
    love.graphics.translate(-p1x, -p1y)

    -- draw background grid
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
    local nw = nr_cells
    local nh = height / 32

    for i = 0, nw do
        -- TODO: read doc -> line
        love.graphics.rectangle('fill', 32 * i, 0, 1, height + 32) 
    end
    for i = 0, nh do
        -- TODO: read doc -> line
        love.graphics.rectangle('fill', 0, 32 * i, width + 32, 1)
    end

    love.graphics.push()
    love.graphics.translate(-p2x, -p2y)

    for i = 0, nr_cells - 1 do
        local ci = i * 255 / 32
        if collision(player, level[i]) then
            print("collision !")
        end
        love.graphics.setColor(ci, 255 - ci, (255 - ci) / 2)
        love.graphics.rectangle('fill', 32 * level[i].pos.x, 32 * level[i].pos.y,
                                32 * level[i].size.x, 32 * level[i].size.y)
    end

    -- draw collision tiles
    love.graphics.setColor(255, 0, 0)

    local x = player.pos.x
    local y = player.pos.y
    local w, h = 32, 32

    c1 = pos2cell(x, y)
    c2 = pos2cell(x + w - 1, y)
    c3 = pos2cell(x, y + h - 1)
    c4 = pos2cell(x + w - 1, y + h - 1)

    -- don't check yet for duplicates...
    love.graphics.rectangle('line', 32 * c1.x, 32 * c1.y, 32, 32)
    love.graphics.rectangle('line', 32 * c2.x, 32 * c2.y, 32, 32)
    love.graphics.rectangle('line', 32 * c3.x, 32 * c3.y, 32, 32)
    love.graphics.rectangle('line', 32 * c4.x, 32 * c4.y, 32, 32)

    -- drawable, x, y, rotation (rad), scale x, scale y, origin offset x, origin offset y
    love.graphics.setColor(255, 255, 255)
    love.graphics.draw(player.img[player.state], x, y, 0, 1, 1, 0, 0)

    love.graphics.pop()
    love.graphics.pop()
end

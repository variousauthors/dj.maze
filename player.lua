require "vector"

local RED   = { 200, 55, 55 }
local BLUE  = { 55, 55, 200 }
local rnd = love.math.newRandomGenerator(os.time())

Player = function (x, y, controls)
    inspect(controls)
    local radius = global.tile_size / 3
    local color  = RED
    local p      = Point(x, y)
    local message = ""
    local score = 0
    local name = "player1"
    local messager = Messager()

    local keypressed = function (key)
        local did_move = true

        if     key == controls.down  then p.setY(p.getY() + global.tile_size)
        elseif key == controls.up    then p.setY(p.getY() - global.tile_size)
        elseif key == controls.right then p.setX(p.getX() + global.tile_size)
        elseif key == controls.left  then p.setX(p.getX() - global.tile_size)
        else did_move = false end

        return did_move
    end

    local isControl = function (key)
        return key == controls.down
            or key == controls.up
            or key == controls.left
            or key == controls.right
    end

    local draw = function ()

        r, g, b = love.graphics.getColor()
        love.graphics.setColor(color)
        love.graphics.circle("fill", p.getX() + global.tile_size / 2, p.getY() + global.tile_size / 2, radius)
        love.graphics.setColor({ r, g, b })
    end

    local getMessage = function ()
        return messager.next_message()
    end

    local setColor = function (c)
        color = c
    end

    local getColor = function (c)
        return color
    end

    local incrementScore = function (inc)
        score = score + inc
    end

    local getScore = function ()
        return score
    end

    local setName = function (n)
        name = n
    end
    
    local getName = function ()
        return name
    end

    return {
        getX           = p.getX,
        getY           = p.getY,
        setX           = p.setX,
        setY           = p.setY,
        setColor       = setColor,
        getColor       = getColor,
        setMessages     = messager.setMessages,
        getMessage     = getMessage,
        incrementScore = incrementScore,
        getScore       = getScore,
        setName        = setName,
        getName        = getName,
        update         = update,
        draw           = draw,
        keypressed     = keypressed,
        isControl      = isControl
    }
end

Enemy = function (x, y)
    -- the difference between player and AI is usually just
    -- a matter of circumstance
    local player = Player(x, y, {
        down  = "down",
        up    = "up",
        left  = "left",
        right = "right"
    })
    local move_index, move_list = 1
    local _keypressed           = player.keypressed

    player.setColor(BLUE)
    player.setName("player2")

    -- read the move list in reverse
    player.getNextMove = function ()
        local move = move_list[move_index]

        move_index = move_index + 1

        return move
    end

    player.setMoveList = function (list)
        move_list = list
    end

    player.isAI = function () return true end

    return player
end

Messager = function (messages)
    local messages = messages

    local next_message = function ()
        local index = rnd:random(1, #messages)

        return messages[index]
    end

    local setMessages = function (msg)
        messages = msg
    end

    return {
        next_message = next_message,
        setMessages  = setMessages
    }
end

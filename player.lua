require "vector"

local RED   = { 200, 55, 55 }
local BLUE  = { 55, 55, 200 }

Player = function (x, y)
    local radius = global.tile_size / 3
    local color  = RED
    local p      = Point(x, y)
    local message = ""
    local score = 0
    local name = "red"

    local keypressed = function (key)
        local did_move = true

        if key == "down"      then p.setY(p.getY() + global.tile_size)
        elseif key == "up"    then p.setY(p.getY() - global.tile_size)
        elseif key == "right" then p.setX(p.getX() + global.tile_size)
        elseif key == "left"  then p.setX(p.getX() - global.tile_size)
        else did_move = false end

        return did_move
    end

    local draw = function ()

        r, g, b = love.graphics.getColor()
        love.graphics.setColor(color)
        love.graphics.circle("fill", p.getX() + global.tile_size / 2, p.getY() + global.tile_size / 2, radius)
        love.graphics.setColor({ r, g, b })
    end

    local setMessage = function (msg)
        message = msg
    end

    local getMessage = function ()
        return message
    end

    local setColor = function (c)
        color = c
    end

    local getColor = function (c)
        return color
    end

    local incrementScore = function (inc)
        inspect({ name, inc })

        score = score + inc
    end

    local getScore = function ()
        return score
    end

    local setName = function(n)
        name = n
    end

    return {
        getX           = p.getX,
        getY           = p.getY,
        setX           = p.setX,
        setY           = p.setY,
        setColor       = setColor,
        getColor       = getColor,
        setMessage     = setMessage,
        getMessage     = getMessage,
        incrementScore = incrementScore,
        getScore       = getScore,
        setName        = setName,
        update         = update,
        draw           = draw,
        keypressed     = keypressed
    }
end

Enemy = function (x, y)
    -- the difference between player and AI is usually just
    -- a matter of circumstance
    local player                = Player(x, y)
    local move_index, move_list = 1
    local _keypressed           = player.keypressed

    player.setColor(BLUE)
    player.setName("blue")

    -- read the move list in reverse
    local getNextMove = function ()
        local move = move_list[move_index]

        move_index = move_index + 1

        return move
    end

    player.setMoveList = function (list)
        move_list = list
    end

    player.keypressed = function (key)

        key = getNextMove()
        return _keypressed(key)
    end

    return player
end

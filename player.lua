require "vector"

Player = function (x, y)
    local radius = global.tile_size / 3
    local p = Point(x, y)

    local keypressed = function (key)
        if key == "down"      then p.setY(p.getY() + global.tile_size)
        elseif key == "up"    then p.setY(p.getY() - global.tile_size)
        elseif key == "right" then p.setX(p.getX() + global.tile_size)
        elseif key == "left"  then p.setX(p.getX() - global.tile_size)
        end
    end

    local update = function (dt)

    end

    local draw = function ()

        love.graphics.setColor(0, 255, 0)
        love.graphics.circle("fill", p.getX() + global.tile_size / 2, p.getY() + global.tile_size / 2, radius)
        love.graphics.setColor(0, 0, 0)
    end

    return {
        getX       = p.getX,
        getY       = p.getY,
        update     = update,
        draw       = draw,
        keypressed = keypressed
    }
end

Enemy = function (x, y)
    -- the difference between player and AI is usually just
    -- a matter of circumstance
    local player = Player(x, y)
    local next_move, move_list = 1

    -- read the move list in reverse
    player.getNextMove = function ()
        local move = move_list[next_move]

        next_move = next_move + 1

        return move
    end

    player.setMoveList = function (list)
        inspect(list)
        move_list = list
    end

    return player
end

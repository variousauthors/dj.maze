require "vector"

Player = function (x, y)
    local radius = global.tile_size / 3

    p = Point(x, y)

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

local Component = require("component")

LANG     = 0
USERNAME = 1
TOKEN    = 2

return function ()
    local showing       = false
    local hide_callback = function () end
    local cursor_pos    = 0
    local arity         = "alone"
    local menu_index    = 0
    local time, flash   = 0, 0

    local inputs = {
        {   -- language_select
            clear      = function ()
                arity      = "alone"
                cursor_pos = 0
            end,
            keypressed = function (key)
                if key == "up" or key == "down" then
                    if arity == "alone" then
                        arity = "together"
                        cursor_pos = 30
                    else
                        arity = "alone"
                        cursor_pos = 0
                    end
                end
            end
        }
    }

    local drawCursor = function (x, y)
        local icon = ">"

        love.graphics.setFont(SCORE_FONT)
        love.graphics.print(icon, x, y + cursor_pos)
    end

    local drawSubtitle = function (x, y)
        love.graphics.setFont(SCORE_FONT)
        love.graphics.printf("find the darkest path to the center", x, y, 576, "right")
    end

    local drawTitle = function (x, y)
        love.graphics.setFont(SPACE_FONT)
        love.graphics.print("DARKEST PATH", x, y)
    end

    local title_part    = Component(0, 0, drawTitle)
    local subtitle_part = Component(0, 80, drawSubtitle)
    local arity_part    = Component(0, 200, Component(0, 0, ""), Component(200, 0, drawCursor), Component(230, 0, "ALONE"), Component(230, 30, "TOGETHER"))

    local component = Component(100, W_HEIGHT/2 - 200, title_part, subtitle_part, arity_part)

    local draw = function ()
        component.draw(0, 0)
    end

    local update = function (dt)
        time  = time + 2*dt
        flash = math.floor(time)%2
    end

    local show = function (callback)
        hide_callback = callback
        showing = true

        if not showing then
            if callback then callback() end
        end
    end

    local hide = function ()
        if hide_callback then hide_callback({ arity = arity }) end
        showing = false
    end

    local isShowing = function ()
        return showing
    end

    local keypressed = function (key)
        if key == "return" then
            hide()
        end

        if inputs[menu_index + 1].keypressed then
            inputs[menu_index + 1].keypressed(key)
        end
    end

    local textinput = function (key)
        if inputs[menu_index + 1].textinput then
            inputs[menu_index + 1].textinput(key)
        end
    end

    return {
        draw           = draw,
        update         = update,
        keypressed     = keypressed,
        textinput      = textinput,
        show           = show,
        hide           = hide,
        isShowing      = isShowing,

        TOGETHER       = "together"
    }

end

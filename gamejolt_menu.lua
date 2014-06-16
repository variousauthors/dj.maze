local Component = require("component")

USERNAME = 0
TOKEN    = 1

return function ()
    local showing       = false
    local hide_callback = function () end
    local cursor_pos    = 0
    local menu_index    = 0
    local username      = ""
    local token         = ""
    local time, flash   = 0, 0

    local inputs = {
        {   -- username
            clear      = function ()
                username = ""
                username_cursor_pos = 200
            end,
            textinput = function (key)
                username = username .. key
            end
        },
        {   -- token
            clear      = function ()
                token = ""
                token_cursor_pos = 200
            end,
            textinput = function (key)
                token = token .. key
            end
        }
    }

    local drawCursor = function (x, y)
        local icon = ""

        love.graphics.print(icon, x + cursor_pos, y)
    end

    local drawUsername = function (x, y)
        local icon = ""
        if flash == 0 and menu_index == USERNAME then icon = "_" end
        
        drawCursor(x, y)
        love.graphics.print(username .. icon, x, y)
    end

    local drawToken = function (x, y)
        local icon = ""
        if flash == 0 and menu_index == TOKEN then icon = "_" end

        drawCursor(x, y)
        love.graphics.print(token .. icon, x, y)
    end

    local talk1         = Component(0, 0, Component(0, 0, "GameJolt API integration"))
    local talk          = Component(0, 30, Component(0, 0, "  Your unique high score is your win/loss ratio against the AI."))
    local username_part = Component(0, 100, Component(0, 0, "USERNAME"), Component(200, 0, drawUsername))
    local token_part    = Component(0, 200, Component(0, 0, "   TOKEN"), Component(200, 0, drawToken))

    local component = Component(100, W_HEIGHT/2 - 200, talk1, talk, username_part, token_part)

    local draw = function ()
        component.draw(0, 0)
    end

    local update = function (dt)
        time = time + 2*dt
        flash = math.floor(time)%2
    end

    local writeProfile = function ()
        local hfile = io.open("profile.lua", "w")
        if hfile == nil then return end

        hfile:write('return { username = "' .. username .. '", token = "' .. token .. '" }')--bad argument #1 to 'write' (string expected, got nil)

        io.close(hfile)
    end

    local findProfile = function ()
        local hfile = io.open("profile.lua", "r")
        local found = hfile ~= nil

        if found then io.close(hfile) end

        return found
    end

    local recoverProfile = function ()
        return require("profile")
    end

    local show = function (callback)
        hide_callback = callback
        showing = true

        if not showing then
            callback()
        end
    end

    local hide = function ()
        hide_callback({ })
        showing = false
    end

    local isShowing = function ()
        return showing
    end

    local keypressed = function (key)
        if menu_index == TOKEN and key == "return" then
            writeProfile()

            hide()
        end

        if key == "down" or (key == "return" and menu_index < (#inputs - 1)) then
            menu_index = (menu_index + 1)%(#inputs)
            inputs[menu_index + 1].clear()
        end

        if key == "up" then
            menu_index = (menu_index - 1)%(#inputs)
            inputs[menu_index + 1].clear()
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
        recoverProfile = recoverProfile,
        isShowing      = isShowing
    }

end

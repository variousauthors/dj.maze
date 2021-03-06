
ScoreBand = function ()
    local band, score = {}, {}
    local timer = 0
    local notice = {
        player1 = "",
        player2 = ""
    }
    local stripe_width, stripe_height = 5, 20

    local addStripe = function (color)
        local stripe = { color = color }

        table.insert(band, stripe)
    end

    local register = function (entity)
        score[entity] = {
            score = 0,
            color = entity.getColor()
        }
    end

    local clear = function ()
        score = {}
    end

    -- returns a score hook that can be used to increment
    -- a score
    local getScoreUpdater = function (entity)

        return function (dt)
            timer = timer + dt
            local rate = 10*math.abs(score[entity].score - entity.getScore())

            if score[entity].score < entity.getScore() then
                score[entity].score = score[entity].score + rate*dt
            end
        end
    end

    local getDifference = function ()
        local diff = 0

        for k, v in pairs(score) do
            diff = math.abs(diff - v.score)
        end

        return diff
    end

    local getFormattedDiff = function ()
        return "|p1 - p2| < " .. getDifference() .. " lm"
    end

    local getResults = function (winner, loser)
        local diff = 0
        local win, lose = "p1", "p2"

        if winner.getName() == "player2" then
            win  = "p2"
            lose = "p1"
        end

        for k, v in pairs(score) do
            diff = math.abs(diff - v.score)
        end

        return win .. " < " .. lose .. " - " .. diff .. " lm"
    end

    local draw = function ()
        local center_line = (W_WIDTH / 2) - global.tile_size / 2

        for k, v in pairs(score) do
            local offset = 0
            local r, g, b = love.graphics.getColor()
            local offset_x = 0
            local score_x, score_y
            local name_x, name_y
            local name_align

            --stripe_width = 20*v.score

            if k.getName() == "player2" then
                --offset_x    = -stripe_width
                score_x = global.tile_size * 2
                score_y = global.tile_size * 1.5
                name_x = - global.map_width / 2 + global.tile_size / 2
                name_y = score_y
                name_align = "left"
            else
                score_x = - global.map_width / 2 + global.tile_size / 2
                score_y = global.map_height + 2.5*global.tile_size
                name_x = score_x
                name_y = score_y
                name_align = "right"
            end

            --love.graphics.setColor(v.color)
            --love.graphics.rectangle("fill", center_line + offset_x, 0, stripe_width, global.tile_size)

            love.graphics.setColor(255, 255, 255)
            love.graphics.setFont(SCORE_FONT)
            love.graphics.printf(v.score .. " lm", center_line + score_x, score_y, W_WIDTH / 2, "left")

            -- TODO this is dumb. Sometimes k is a player, sometimes it is a maze object.
            -- it should just always be a player
            if k.isMaze then
                if k.playTogether() then
                    love.graphics.printf(k.getName(), center_line + name_x, name_y, W_WIDTH / 2 + 75, name_align)
                else
                    if math.floor(timer)%2 == 0 then
                        love.graphics.printf(notice[k.getName()], center_line + name_x, name_y, W_WIDTH / 2 + 75, name_align)
                    end
                end
            else
                love.graphics.printf(k.getName(), center_line + name_x, name_y, W_WIDTH / 2 + 75, name_align)
            end
        end

        for index, stripe in ipairs(band) do

            love.graphics.setColor(stripe.color)
            love.graphics.rectangle("fill", center_line - global.map_width/2 + index*5 + stripe_width/2, 0, stripe_width, stripe_height)
        end

        love.graphics.setColor({ r, g, b })
    end

    local setNotice = function (key, text)
        notice[key] = text
    end

    return {
        draw             = draw,
        addStripe        = addStripe,
        getScoreUpdater  = getScoreUpdater,
        register         = register,
        getResults       = getResults,
        getDifference    = getDifference,
        getFormattedDiff = getFormattedDiff,
        setNotice        = setNotice,
        clear            = clear
    }
end

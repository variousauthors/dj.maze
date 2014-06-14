
ScoreBand = function ()
    local band, score = {}, {}
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
            local rate = 10*math.abs(score[entity].score - entity.getScore())

            if score[entity].score < entity.getScore() then
                score[entity].score = score[entity].score + rate*dt
            end
        end
    end

    local getResults = function ()
        local diff = 0

        for k, v in pairs(score) do
            diff = math.abs(diff - v.score)
        end

        return "|p1 - p2| < " .. diff
    end

    local draw = function ()
        local center_line = (W_WIDTH / 2) - global.tile_size / 2

        for k, v in pairs(score) do
            local offset = 0
            local r, g, b = love.graphics.getColor()
            local text_width = W_WIDTH / 8
            local offset_x, text_align = 0, "left"
            local text_offset_x = - global.map_width / 2 + global.tile_size / 2
            local text_offset_y = global.map_height + 2.5*global.tile_size

            --stripe_width = 20*v.score

            if k.getName() == "player1" then
                --offset_x    = -stripe_width
                text_offset_y = global.tile_size * 1.5
            end

            --love.graphics.setColor(v.color)
            --love.graphics.rectangle("fill", center_line + offset_x, 0, stripe_width, global.tile_size)

            love.graphics.setColor(255, 255, 255)
            love.graphics.setFont(SCORE_FONT)
            love.graphics.printf(v.score, center_line + text_offset_x, text_offset_y, text_width, text_align)
        end

        for index, stripe in ipairs(band) do

            love.graphics.setColor(stripe.color)
            love.graphics.rectangle("fill", center_line - global.map_width/2 + index*5 + stripe_width/2, 0, stripe_width, stripe_height)
        end

        love.graphics.setColor({ r, g, b })
    end

    return {
        draw            = draw,
        addStripe       = addStripe,
        getScoreUpdater = getScoreUpdater,
        register        = register,
        getResults      = getResults,
        clear           = clear
    }
end

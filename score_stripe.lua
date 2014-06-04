
ScoreBand = function ()
    local band, score = {}, {}

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

    local draw = function ()
        local offset = 0
        local r, g, b = love.graphics.getColor()

        for k, v in pairs(score) do
            local text_width = W_WIDTH / 8
            local offset_x, text_align = 0, "left"
            local text_offset_x = - global.map_width / 2 + global.tile_size / 2
            local text_offset_y = global.map_height + 2.5*global.tile_size
            local center_line = (W_WIDTH / 2) - global.tile_size / 2

            stripe_width = 20*v.score

            if k.getName() == "red" then
                offset_x    = -stripe_width
                text_offset_y = global.tile_size * 1.5
            end

            love.graphics.setColor(v.color)
            love.graphics.rectangle("fill", center_line + offset_x, 0, stripe_width, global.tile_size)

            love.graphics.setColor(255, 255, 255)
            love.graphics.setFont(SCORE_FONT)
            love.graphics.printf(v.score, center_line + text_offset_x, text_offset_y, text_width, text_align)
        end

        love.graphics.setColor({ r, g, b })
    end

    return {
        draw            = draw,
        addStripe       = addStripe,
        getScoreUpdater = getScoreUpdater,
        register        = register
    }
end

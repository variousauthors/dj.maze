
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
            stripe_width = 20*v.score
            love.graphics.setColor(v.color)
            love.graphics.rectangle("fill", 0, offset, stripe_width, 20)
            offset = offset + 20
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


ScoreBand = function ()
    local band = {}

    local addStripe = function (color)
        local stripe = { color = color }

        table.insert(band, stripe)
    end

    local draw = function ()
        r, g, b = love.graphics.getColor()

        for index, stripe in ipairs(band) do
            love.graphics.setColor(stripe.color)
            love.graphics.rectangle("fill", 0 + index * 5, 0, 5, 20)
        end

        love.graphics.setColor({ r, g, b })
    end

    return {
        draw      = draw,
        addStripe = addStripe
    }
end

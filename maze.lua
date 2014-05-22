
Maze = function (width, height)
    local colors = {
        solid_color = { 200, 55, 55 },
        floor_color = { 35, 35, 35}
    }

    local structure = {
        { 1, 0, 0 },
        { 0, 1, 0 },
        { 1, 1, 1 },
    }

    local draw = function ()
        for i = 1, height do
            row = i

            for j = 1, width do
                col = j-- reversing the index, 3 downto 1

                local solid = structure[row][col] == 1

                love.graphics.setColor(colors.floor_color)
                if solid then
                    love.graphics.setColor(colors.solid_color)
                end

                local x = col * global.tile_size
                local y = row * global.tile_size

                love.graphics.rectangle("fill", x, y, global.tile_size, global.tile_size)
            end
        end
    end

    structure.draw = draw

    return structure
end

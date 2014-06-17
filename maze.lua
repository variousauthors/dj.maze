local GOAL           = 1*math.pow(10, -16) -- too small to affect the score ^o^//
local MAX_BRIGHTNESS = 1000
local weight_scale   = 3
local visual_scale   = { r = 2, g = 1, b = 1 }
local FULL           = 100
local adjust         = { r = 0, g = 0, b = 0 }
local ADJUST         = 50

Maze = function (x, y, width, height)
    local structure, adjacencies, path
    local enemy, goal, winner

    local offset_x, offset_y = x, y
    local pixel_width        = offset_x + (width - 1)  * global.tile_size
    local pixel_height       = offset_y + (height - 1) * global.tile_size
    local brightness, timer  = MAX_BRIGHTNESS, 0

    local getPixelX = function (x)
        return x * global.tile_size + offset_x
    end

    local getPixelY = function (y)
        return y * global.tile_size + offset_y
    end

    local getTileX = function (x)
        return math.floor((x - offset_x) / global.tile_size) + 1
    end

    local getTileY = function (y)
        return math.floor((y - offset_y) / global.tile_size) + 1
    end

    local rowColFromIndex = function (index)
        return math.floor(((index - 1)/height) + 1), (index - 1)%width + 1
    end

    local playTogether = function ()
        return enemy.getNextMove == nil
    end

    local colors = {
        solid_color = { 200, 55, 55 },
        floor_color = { 35, 35, 35},
        goal_color  = { 0, 0, 0 }
    }

    local getWeight = function (x, y)
        local col, row = getTileX(x), getTileY(y)

        return structure[row][col]
    end

    local setWeight = function (x, y, weight)
        local col, row = getTileX(x), getTileY(y)

        print("===")
        inspect({ col, row })
        inspect({ width - col + 1, row })
        inspect({ col, height - row + 1 })
        inspect({ width - col + 1, height - row + 1 })
        structure[row][col]                          = math.min(weight, 1)
        structure[height - row + 1][col]             = math.min(weight, 1)
        structure[row][width - col + 1]              = math.min(weight, 1)
        structure[height - row + 1][width - col + 1] = math.min(weight, 1)
    end

    -- offset_x < player.getX() < offset_x + width * global.tile_size
    local tryMove = function (player, key)
        local old_x = player.getX()
        local old_y = player.getY()
        local moved = true

        player.keypressed(key)

        if offset_x > player.getX() or player.getX() > pixel_width              then moved = false
        elseif offset_y > player.getY() or player.getY() > pixel_height         then moved = false
        end

        if moved == false then
            player.setX(old_x)
            player.setY(old_y)
        else
            local old_weight = getWeight(old_x, old_y)
            player.incrementScore(getWeight(player.getX(), player.getY()))
            if dynamic_mode == true then
                setWeight(old_x, old_y, old_weight * 2)
            end
            player.updateEcho(old_x, old_y)
        end

        return moved
    end

    -- only move the enemy if the player moved
    local keypressed = function (key, player)
        if not tryMove(player, key) then return end

        -- if the enemy is an AI, then get their move
        if enemy.getNextMove then
            local old_x = enemy.getX()
            local old_y = enemy.getY()

            key = enemy.getNextMove()

            if enemy.keypressed(key) then
                local old_weight = getWeight(old_x, old_y)
                enemy.incrementScore(getWeight(enemy.getX(), enemy.getY()))
                if dynamic_mode == true then
                    setWeight(old_x, old_y, old_weight * 2)
                end
                enemy.updateEcho(old_x, old_y)
            end
        end
    end

    local getScore = function ()
        return enemy.getScore()
    end

    local getColor = function ()
        return enemy.getColor()
    end

    local getWinner = function ()
        return winner
    end

    local getLoser = function ()
        return loser
    end

    local lose = function ()
        winner = enemy
        loser  = player

        return enemy
    end

    local setMessages = function (messages)
        enemy.setMessages(messages)
    end

    local chooseWinner = function ()
        winner = player
        loser  = enemy

        -- whoever has collected the most weight loses
        if enemy.getScore() < player.getScore() then
            winner = enemy
            loser  = player
        end

        return winner
    end

    -- TODO ha ha ha, this function totally looks rad because
    -- of integer overflow. Yay integer overflow!
    local fadeOut = function (dt)
        local diff = MAX_BRIGHTNESS - brightness
        brightness = brightness - diff - dt
    end

    local dynamicMode = function ()
        dynamic_mode = true
    end

    local update = function (dt)
        timer = timer + dt
        local goal_x = goal.getX() * global.tile_size + offset_x
        local goal_y = goal.getY() * global.tile_size + offset_y

        if player.getX() == goal_x and player.getY() == goal_y then
            if enemy.getX() == goal_x and enemy.getY() == goal_y then
                winner = chooseWinner()
            end
        end
    end

    local draw = function ()
        local r, g, b = love.graphics.getColor()
        love.graphics.push()
        love.graphics.scale(global.scale)

        for i = 1, height do
            row = i

            for j = 1, width do
                col = j-- reversing the index, 3 downto 1

                local goal  = structure[row][col] == GOAL

                local red   = ADJUST + (FULL-adjust.r)*(math.pow(structure[row][col], visual_scale.r))
                local green = ADJUST + (FULL-adjust.g)*(math.pow(structure[row][col], visual_scale.g))
                local blue  = ADJUST + (FULL-adjust.b)*(math.pow(structure[row][col], visual_scale.b))
                local color = { red, green, blue, brightness }

                love.graphics.setColor(color)
                if goal  then love.graphics.setColor(colors.goal_color) end

                local x = (col - 1) * global.tile_size
                local y = (row - 1) * global.tile_size

                love.graphics.rectangle("fill", x + offset_x, y + offset_y, global.tile_size, global.tile_size)
            end
        end

        love.graphics.setColor({ r, g, b})
        enemy.draw()
        love.graphics.pop()
    end

    -- given an adjacency matrix A[][] returns a table
    -- P containing the shortest path from nodes a to b
    local shortestPath = function (adjacencies, a, b)
        local visited, d = {}, {}
        local path = {}

        -- initialize the visited table
        for i = 1, #adjacencies do
            visited[i] = 0
            path[i] = a

            -- initialize the edges coming from a
            if adjacencies[a][i].open > 0 then
                d[i] = adjacencies[a][i].weight
            end
        end

        visited[1] = 1

        for i = 1, #adjacencies do
            local v   = nil
            local min = 1

            -- take the first unexplored node
            local j = 1
            while (j <= #adjacencies) do
                if visited[j] == 0 and d[j] ~= nil and d[j] <= min then
                    min = d[j]
                    v = j
                end
                j = j + 1
            end

            if v ~= nil then
                visited[v] = 1

                -- adjust the distances of the other nodes
                for j = 1, #adjacencies do
                    -- for each unexplored node with an edge to v,
                    -- if the distance from s to j is less than
                    -- the distance from s to v plus the distance from
                    -- v to j, then decrease the distance
                    if visited[j] == 0 and adjacencies[v][j].open > 0 then
                        -- if there is an unexplored edge vj

                        -- at every step we mark the edge j as having
                        -- been arrived at via v

                        if d[j] == nil then
                            d[j] = d[v] + adjacencies[v][j].weight
                            path[j] = v
                        elseif d[j] > d[v] + adjacencies[v][j].weight then
                            d[j] = d[v] + adjacencies[v][j].weight
                            path[j] = v
                        end
                    end
                end
            end
        end

        return path
    end

    local instructionFromRowCol = function (frow, fcol, trow, tcol)
        if     frow > trow then return "up"
        elseif frow < trow then return "down"
        elseif fcol > tcol then return "left"
        elseif fcol < tcol then return "right"
        end
    end

    -- starting at the end of the path build the reverse
    -- path, and then reverse it
    local moveListFromPath = function (path)
        local move_list = {}
        local index = width*height

        while(index > 1) do
            local from_row, from_col = rowColFromIndex(path[index])
            local to_row, to_col     = rowColFromIndex(index)

            local instruction = instructionFromRowCol(from_row, from_col, to_row, to_col)
            table.insert(move_list, instruction)

            index = path[index]
        end

        return move_list
    end

    local rng = love.math.newRandomGenerator(os.time())

    local init = function ()
        structure, adjacencies = {}, {}

        for i = 1, height do
            structure[i] = {}

            -- try weight inversely proportional to
            -- product of indices
            for j = 1, width do
                local n = rng:random()

                structure[i][j] = math.pow(n, weight_scale)
            end
        end

        local isSolid = function (t_row, t_col)
            return structure[t_row][t_col] == nil
        end

        local exists = function (t_row, t_col)
            return structure[t_row] ~= nil and structure[t_row][t_col] ~= nil
        end

        local isAdjacent = function (t_row, t_col, a_row, a_col)
            local result = false

            -- a tile is adjacent to another if
            --   the tile has the same t_row but different t_col
            --   the tile has the same t_col but different t_row
            
            if t_row == a_row then
                result = ((t_col + 1) == a_col or (t_col - 1) == a_col)

            elseif t_col == a_col then
                result = ((t_row + 1) == a_row or (t_row - 1) == a_row)
            end

            return result
        end

        local isEqual = function (t_row, t_col, a_row, a_col)
            return t_row == a_row and t_col == a_col
        end

        -- initialize the adjacency matrix
        for i = 1, height * width do
            -- consider a tile
            adjacencies[i] = {}

            -- tile coords
            local t_row, t_col = rowColFromIndex(i)

            for j = 1, height * width do
                -- adjacency coords
                local a_row, a_col = rowColFromIndex(j)
                
                -- if the tile is not solid, mark
                --if structure[t_row][t_col] == 0 then

                    -- if the potential adjacency is not the tile
                    -- if the potential adjacency is not solid
                    -- if the potential adjacency is adjacent
                    if  not isSolid(a_row, a_col)
                        and not isEqual(t_row, t_col, a_row, a_col)
                        and isAdjacent(t_row, t_col, a_row, a_col)
                        then

                        adjacencies[i][j] = { open = 1, weight = structure[t_row][t_col] }
                    else
                        adjacencies[i][j] = { open = 0 }
                    end
                --else
                 --   adjacencies[i][j] = { open = 0 }
                --end
            end
        end

        path = shortestPath(adjacencies, 1, height * width)

        return {
            draw         = draw,
            update       = update,
            keypressed   = keypressed,
            getPixelX    = getPixelX,
            getPixelY    = getPixelY,
            getWinner    = getWinner,
            getLoser     = getLoser,
            lose         = lose,
            getScore     = getScore,
            getColor     = getColor,
            dynamicMode  = dynamicMode,
            fadeOut      = fadeOut,
            setMessages  = setMessages,
            playTogether = playTogether
        }
    end

    local obj = init()

    -- this is the enemy's position for their initial calculations
    enemy = Enemy(getPixelX(width - 1), getPixelY(height - 1))
    enemy.setMoveList(moveListFromPath(path))
    obj.getName = enemy.getName
    obj.isMaze = true

    obj.setEnemy = function (player)
        -- replace the AI opponent with a player
        enemy = player
    end

    -- create a new table with n + n - 1 rows
    -- copy the existing table into the top or bottom
    -- of the new table (based on direction)
    -- then copy the mirror image of the existing
    -- table into the rest of the table
    local axialMirrorRows = function (table, direction)
        local structure = {}
        local middle    = #table -- the middle index of the new table
        -- reset the dimensions
        height          = #table*2 - 1
        width           = #table[1]

        -- either copy into the beginning of the table
        -- or copy from the middle of the table
        -- this is an offset from the index into the structure
        if direction == "up" then
            start_offset = middle - 1
        else
            start_offset = 0
        end

        -- copy each row of the old table into the structure
        for i = 1, #table do
            local index = i + start_offset

            structure[index] = table[i]
        end

        for i = 1, middle - 1 do
            local skip = 0
            if start_offset ~= 0 then skip = 1 end
            local index = i + (middle - start_offset - skip)

            structure[index] = table[#table - i + 1]
        end

        return structure
    end

    local axialMirrorCols = function (table, direction)
        local structure = {}
        local middle    = #table[1] -- the middle index of the new table
        -- reset the dimensions
        height          = #table
        width           = #table[1]*2 - 1

        -- either copy into the beginning of the table
        -- or copy from the middle of the table
        -- this is an offset from the index into the structure
        if direction == "left" then
            start_offset = middle - 1
        else
            start_offset = 0
        end

        -- copy each col of the old table into the structure
        for i = 1, middle do
            local col_index = i + start_offset


            -- copy the col value of each row
            for j = 1, #table do
                if structure[j] == nil then structure[j] = {} end

                structure[j][col_index] = table[j][i]
            end
        end

        for i = 1, middle - 1 do
            local skip = 0
            if start_offset ~= 0 then skip = 1 end
            local col_index = i + (middle - start_offset - skip)

            --structure[col_index] = table[#table - i]
            -- copy the col value of each row
            for j = 1, #table do
                structure[j][col_index] = table[j][#table[1] - i + 1]
            end
        end

        return structure
    end

    -- take the quarter sized board and reflect it
    structure = axialMirrorRows(structure, "up")
    structure = axialMirrorCols(structure, "left")

    -- after mirroring, the AI's starting position must be changed to the new corner
    enemy.setX(getPixelX(0))
    enemy.setY(getPixelY(0))

    pixel_width  = offset_x + (width - 1)  * global.tile_size
    pixel_height = offset_y + (height - 1) * global.tile_size

    goal = Point(math.floor(width / 2), math.floor(height / 2))
    structure[goal.getX() + 1][goal.getY() + 1] = GOAL

    return obj
end

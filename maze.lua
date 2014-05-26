
Maze = function (width, height)
    local structure, adjacencies

    local colors = {
        solid_color = { 200, 55, 55 },
        floor_color = { 35, 35, 35}
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

    -- given an adjacency matrix A[][] returns a table
    -- P containing the shortest path from nodes a to b
    local shortestPath = function (adjacencies, a, b)
        local visited, d = {}, {}

        -- initialize the visited table
        for i = 1, #adjacencies do
            visited[i] = 0

            -- initialize the edges coming from a
            if adjacencies[a][i] > 0 then
                d[i] = adjacencies[a][i]
            end
        end

        visited[1] = 1

        for i = 1, #adjacencies do
            local v = nil

            -- take the first unexplored node
            local j = 1
            while (v == nil and j <= #adjacencies) do
                if visited[j] == 0 and d[j] ~= nil then
                    v = j
                end
                j = j + 1
            end

            print(v)
            if v ~= nil then
                visited[v] = 1

                -- adjust the distances of the other nodes
                for j = 1, #adjacencies do
                    -- for each unexplored node with an edge to v,
                    -- if the distance from s to j is less than
                    -- the distance from s to v plus the distance from
                    -- v to j, then decrease the distance
                    if visited[j] == 0 and adjacencies[v][j] > 0 then
                        -- if there is an unexplored edge vj

                        if d[j] == nil then
                            d[j] = d[v] + adjacencies[v][j]
                        elseif d[j] > d[v] + adjacencies[v][j] then
                            d[j] = d[v] + adjacencies[v][j]
                        end
                    end
                end
            end
        end

        inspect(d)
    end

    local init = function ()
        local rng = love.math.newRandomGenerator(os.time())
        structure, adjacencies = {}, {}

        for i = 1, height do
            structure[i] = {}

            for j = 1, width do
                structure[i][j] = rng:random(0, 1)
            end
        end

        local isSolid = function (t_row, t_col)
            return structure[t_row][t_col] == 1
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
        print ("   1, 2, 3, 4, 5, 6, 7, 8, 9")
        print ("   --------------------------")
        for i = 1, height * width do
            -- consider a tile
            bob = "" .. i .. ": "
            adjacencies[i] = {}

            -- tile coords
            local t_row, t_col = math.floor(((i - 1)/3) + 1), (i - 1)%3 + 1

            for j = 1, height * width do
                -- adjacency coords
                local a_row, a_col = math.floor(((j - 1)/3) + 1), (j - 1)%3 + 1
                
                -- if the tile is not solid, mark
                if structure[t_row][t_col] == 0 then

                    -- if the potential adjacency is not the tile
                    -- if the potential adjacency is not solid
                    -- if the potential adjacency is adjacent
                    if  not isSolid(a_row, a_col)
                        and not isEqual(t_row, t_col, a_row, a_col)
                        and isAdjacent(t_row, t_col, a_row, a_col)
                        then

                        bob = bob .. "1, "
                        adjacencies[i][j] = 1
                    else
                        bob = bob .. "0, "
                        adjacencies[i][j] = 0
                    end
                else
                    bob = bob .. "0, "
                    adjacencies[i][j] = 0
                end
            end

            print(bob)
            bob = ""
        end

        shortestPath(adjacencies, 1, height * width)

        return {
            draw = draw
        }
    end

    return init()
end


Game = function ()
    local score   = 0

    local RED    = { 200, 55, 0 }
    local GREEN  = { 0, 200, 55 }
    local BLUE   = { 55, 0, 200 }

    W_WIDTH  = love.window.getWidth()
    W_HEIGHT = love.window.getHeight()

    SCORE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 14)
    SPACE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 64)

    local main, maze, menu = {}
    local maze_d, maze     = 16
    local play_together    = false

    global.tile_size  = math.min(W_WIDTH, W_HEIGHT - 100)/(2*maze_d)
    global.map_width  = global.tile_size * 2 * maze_d
    global.map_height = global.tile_size * 2 * maze_d

    local origin = Point((W_WIDTH - global.map_width) / 2, (W_HEIGHT - global.map_height) / 2)

    local init = function (score_band)
        maze   = Maze(origin.getX(), origin.getY(), maze_d, maze_d)
        player = Player(maze.getPixelX((maze_d - 1) * 2), maze.getPixelY((maze_d - 1) * 2), {
            down = "down", up = "up", left = "left", right = "right"
        })

        player.setMessages({ "You Win!" })
        maze.setMessages({ "So Close!", "Keep Trying!", "Almost!", "Nice Try!", "Oh No!", "Close One", "Oops" })

        if play_together then
            player2 = Player(maze.getPixelX(0), maze.getPixelY(0), {
                down = "s", up = "w", left = "a", right = "d"
            })
            player2.setColor(BLUE)
            player2.setName("player2")
            player2.setMessages({ player2.getName() .. " Wins!" })
            player.setMessages({ player.getName() .. " Wins!" })
            maze.setEnemy(player2)
        end

        score_band.clear()
        score_band.register(player)
        score_band.register(maze)

        if play_together then
            score_band.setNotice("player2", "")
        else
            score_band.setNotice("player2", "press return")
        end

        maze.updateScore   = score_band.getScoreUpdater(maze)
        player.updateScore = score_band.getScoreUpdater(player)
    end

    local playTogether = function ()
        play_together = true
    end

    local playAlone = function ()
        play_together = false
    end

    local draw = function ()
        maze.draw()
        player.draw()
    end

    local keypressed = function (key)
        if play_together and player2.isControl(key) then
            if (player2) then
                maze.keypressed(key, player2)
            end
        end

        if player.isControl(key) then
            maze.keypressed(key, player)
        end
    end

    local update = function (dt)
        maze.updateScore(dt)
        player.updateScore(dt)

        if gameIsPaused then return end

        love.audio.update()

        maze.update(dt)
    end

    local getWinner = function ()
        return maze.getWinner()
    end

    local getLoser = function ()
        return maze.getLoser()
    end

    local flicker = function (dt)
        maze.fadeOut(dt)
    end

    local updateScore = function (dt)
        maze.updateScore(dt)
    end

    local isAlone = function ()
        return play_together == false
    end

    return {
        draw         = draw,
        update       = update,
        keypressed   = keypressed,
        init         = init,
        getWinner    = getWinner,
        getLoser     = getLoser,
        flicker      = flicker,
        updateScore  = updateScore,
        getWinner    = getWinner,
        isAlone      = isAlone,
        playTogether = playTogether,
        playAlone    = playAlone
    }

end

global = {}
global.tile_size = 16
global.scale = 1

require "player"
require "audio"
require "maze"
require "fsm"
require "score_stripe"

local i = require("vendor/inspect/inspect")
inspect = function (a, b)
    print(i.inspect(a, b))
end

function math.round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

local time    = 0
local score   = 0

local RED    = { 200, 55, 0 }
local GREEN  = { 0, 200, 55 }
local BLUE   = { 55, 0, 200 }

W_WIDTH  = love.window.getWidth()
W_HEIGHT = love.window.getHeight()

SCORE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 14)
COUNTDOWN_FONT = love.graphics.newFont("assets/Audiowide-Regular.ttf", 256)
SPACE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 64)

local main = {}
local countdown = 3.5
local bgm
local maze_d, maze = 16
local victory_message, results

global.tile_size  = math.min(W_WIDTH, W_HEIGHT - 100)/(2*maze_d)
global.map_width  = global.tile_size * 2 * maze_d
global.map_height = global.tile_size * 2 * maze_d

local origin = Point((W_WIDTH - global.map_width) / 2, (W_HEIGHT - global.map_height) / 2)
local score_band

local debounce = false

local init = function ()
    maze   = Maze(origin.getX(), origin.getY(), maze_d, maze_d)
    player = Player(maze.getPixelX(0), maze.getPixelY(0))
    player.setMessages({ "You Win!" })
    maze.setMessages({ "So Close!", "Keep Trying!", "Almost!", "Nice Try!", "Oh No!", "Close One", "Oops" })

    score_band.clear()
    score_band.register(player)
    score_band.register(maze)

    maze.updateScore   = score_band.getScoreUpdater(maze)
    player.updateScore = score_band.getScoreUpdater(player)
end

function love.focus(f) gameIsPaused = not f end

function main.draw()
    maze.draw()
    player.draw()
    score_band.draw()

    if (maze.getWinner() ~= nil) then
        -- draw the prompt
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(SPACE_FONT)
        love.graphics.printf(victory_message, -10, W_HEIGHT / 2 - global.tile_size * 5.5, W_WIDTH, "center")
        love.graphics.setFont(SCORE_FONT)
        love.graphics.printf(results, -10, W_HEIGHT / 2, W_WIDTH, "center")
    end
end

function main.keypressed(key)
    if (key == "escape") then
        love.event.quit()
    end

    if winner ~= nil then return init() end

    -- press space to give up
    if (key == " ") then
        print("space")

        -- if the player has given up prematurely, they lose
        if (winner == nil) then
            print("winner was nil")
            winner = maze.lose()
            score_band.addStripe(winner.getColor())
            victory_message = "Dream Big!"
            results = ""
        else
            init()
        end
    end

    if (love.keyboard.isDown("w", "a", "s", "d")) then
        -- TODO player2's moves go here
    elseif (love.keyboard.isDown("down", "up", "right", "left")) then
        maze.keypressed(key, player)
    end
end

function main.update(dt)
    maze.updateScore(dt)
    player.updateScore(dt)

    if maze.getWinner() ~= nil then return end
    if gameIsPaused then return end

    love.audio.update()

    time = time + dt

    if (countdown > 0) then
        countdown = countdown - dt * 2
    end

    maze.update()
    winner = maze.getWinner()

    if (winner ~= nil) then
        score_band.addStripe(winner.getColor())
        victory_message = winner.getMessage()
        results = score_band.getResults()
    end
end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    score_band = ScoreBand()

    state_machine = FSM()

    state_machine.addState({
        name       = "start",
        init       = init,
        draw       = main.draw,
        update     = main.update,
        keypressed = main.keypressed
    })
    
    state_machine.addState({
        name       = "stop",
        init       = function () end,
        draw       = function ()
            love.graphics.printf("WAT", -10, W_HEIGHT / 2 - global.tile_size * 5.5, W_WIDTH, "center")
        end,
        update     = function () end,
        keypressed = function () end
    })

    state_machine.addTransition({
        from      = "start",
        to        = "stop",
        condition = function ()
            return maze.getWinner() ~= nil
        end
    })

    love.update = state_machine.update
    state_machine.start()
    --bgm = love.audio.play("assets/Jarek_Laaser_-_Pump_It_Up.mp3", "stream", true) -- stream and loop background music
end


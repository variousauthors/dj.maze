global = {}
global.tile_size = 16

require "player"
require "audio"
require "maze"
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

local W_WIDTH  = love.window.getWidth()
local W_HEIGHT = love.window.getHeight()

local SCORE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 14)
local COUNTDOWN_FONT = love.graphics.newFont("assets/Audiowide-Regular.ttf", 256)
local SPACE_FONT     = love.graphics.newFont("assets/Audiowide-Regular.ttf", 64)

local countdown = 3.5
local gameOver  = false
local bgm
local origin = Point(100, 100)
local maze_d, maze = 13
local score_band

local debounce = false

local init = function ()
    maze   = Maze(origin.getX(), origin.getY(), maze_d, maze_d)
    player = Player(maze.getPixelX(0), maze.getPixelY(0))
    player.setMessage("YOU WIN")
end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    init()
    score_band = ScoreBand()

    --bgm = love.audio.play("assets/Jarek_Laaser_-_Pump_It_Up.mp3", "stream", true) -- stream and loop background music
end

function love.keypressed(key)
    maze.keypressed(key, player)
end

function love.draw()
    -- draw the map
    -- draw the dudes
    -- draw the goal
    -- draw the HUD
    
    maze.draw()
    player.draw()
    score_band.draw()

    if (maze.getWinner() ~= nil) then
        -- draw the prompt
        love.graphics.setColor(255, 255, 255)
        love.graphics.setFont(SPACE_FONT)
        love.graphics.printf(maze.getWinner().getMessage(), -10, W_HEIGHT / 2 - 175, W_WIDTH, "center")
    end
end

function love.focus(f) gameIsPaused = not f end

-- if the game is over, press space to go again!
function love.keyreleased(key)
    -- press escape to quit
    if (key == "escape") then
        love.event.quit()
    end

    -- press space to give up
    if (key == " ") then
        gameOver  = false

        init()
        --love.audio.stop(bgm)
        --love.audio.play(bgm)
    end
end

function love.update(dt)
    if maze.getWinner() ~= nil then return end
    if gameIsPaused then return end

    love.audio.update()

    time = time + dt

    if (countdown > 0) then
        countdown = countdown - dt * 2
    end

    maze.update()

    if (maze.getWinner() ~= nil) then
        score_band.addStripe(maze.getWinner().getColor())
    end
end



require "player"
require "audio"
require "maze"

local i = require("vendor/inspect/inspect")
inspect = function (a, b)
    print(i.inspect(a, b))
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
local origin = Point(200, 200)
local maze   = Maze(origin.getX(), origin.getY(), 10, 10)

local debounce = false

global = {}
global.tile_size = 16

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)
    player = Player(origin.getX(), origin.getY())

    --bgm = love.audio.play("assets/Jarek_Laaser_-_Pump_It_Up.mp3", "stream", true) -- stream and loop background music
end

function love.keypressed(key)
    player.keypressed(key)
end

function love.draw()
    -- draw the map
    -- draw the dudes
    -- draw the goal
    -- draw the HUD
    
    maze.draw()
    player.draw()

    if (gameOver) then
        -- draw the prompt
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(SPACE_FONT)
        love.graphics.printf("press space", -10, W_HEIGHT / 2 - 175, W_WIDTH, "center")
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
        love.audio.stop(bgm)
        love.audio.play(bgm)
    end
end

function love.update(dt)
    if gameIsPaused then return end

    love.audio.update()

    time = time + dt

    if (countdown > 0) then
        countdown = countdown - dt * 2
    end

    player.update()
end



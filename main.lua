global = {}
global.tile_size = 16
global.scale = 1

require "player"
require "audio"
require "game"
require "maze"
require "fsm"
require "score_band"
local Menu = require("menu")

local i = require("vendor/inspect/inspect")
inspect = function (a, b)
    print(i.inspect(a, b))
end

function math.round(val, decimal)
  local exp = decimal and 10^decimal or 1
  return math.ceil(val * exp - 0.5) / exp
end

local victory_message, results

function love.focus(f) gameIsPaused = not f end

function love.load()
    love.graphics.setBackgroundColor(0, 0, 0)

    score_band = ScoreBand()
    game       = Game()
    menu       = Menu()

    state_machine = FSM()

    state_machine.addState({
        name       = "run",
        init       = function ()
            game.init(score_band)
        end,
        draw       = function ()
            game.draw()
            score_band.draw()
        end,
        update     = game.update,
        keypressed = game.keypressed
    })

    state_machine.addState({
        name       = "start",
        init       = function ()
            menu.show(function (options)
                if options.arity == menu.TOGETHER then
                    game.playTogether()
                end
            end)
        end,
        draw       = menu.draw,
        keypressed = menu.keypressed,
        update     = menu.update
    })
    
    state_machine.addState({
        name       = "stop",
        draw       = function ()
            love.graphics.printf("WAT", -10, W_HEIGHT / 2 - global.tile_size * 5.5, W_WIDTH, "center")
        end,
    })

    state_machine.addState({
        name       = "win",
        init       = function ()
            local winner = game.getWinner()
            -- TODO find a better way to incorporate the stripe
            --score_band.addStripe(winner.getColor())

            victory_message = winner.getMessage()
        end,
        update = function (dt)
            game.updateScore(dt)
            player.updateScore(dt)
            results         = score_band.getResults()

            game.flicker(dt)
        end,
        draw       = function ()
            game.draw()
            score_band.draw()

            -- draw the prompt
            love.graphics.setColor(255, 255, 255)
            love.graphics.setFont(SPACE_FONT)
            love.graphics.printf(victory_message, -10, W_HEIGHT / 2 - global.tile_size * 5.5, W_WIDTH, "center")
            love.graphics.setFont(SCORE_FONT)
            love.graphics.printf(results, -10, W_HEIGHT / 2, W_WIDTH, "center")
        end
    })

    -- start the game when the player chooses a menu option
    state_machine.addTransition({
        from      = "start",
        to        = "run",
        condition = function ()
            if menu.choice == menu.TOGETHER then
                game.playTogether()
            end

            return not menu.isShowing()
        end
    })

    -- reset the game if there is a winner
    state_machine.addTransition({
        from      = "run",
        to        = "win",
        condition = function ()
            return game.getWinner() ~= nil
        end
    })

    state_machine.addTransition({
        from      = "stop",
        to        = "run",
        condition = function ()
            return false
        end
    })

    -- restart the game if the player presses space
    state_machine.addTransition({
        from      = "run",
        to        = "run",
        condition = function ()
            return game.getWinner() == nil and game.isAlone() and state_machine.isSet(" ")
        end
    })

    -- restart the game if the player presses space
    state_machine.addTransition({
        from      = "win",
        to        = "run",
        condition = function ()
            return state_machine.isSet(" ")
        end
    })

    love.update     = state_machine.update
    love.keypressed = state_machine.keypressed
    love.draw       = state_machine.draw

    state_machine.start()
end


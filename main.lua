global = {}
global.tile_size = 16
global.scale = 1

require "player"
require "audio"
require "game"
require "maze"
require "fsm"
require "score_band"
require "gamejolt"

local Menu = require("menu")
local GJMenu = require("gamejolt_menu")

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
    gj_menu    = GJMenu()
    gj         = GameJolt("1", nil)

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

    local profile = nil

    state_machine.addState({
        name       = "start",
        init       = function ()
            game.set("together", nil)
            game.set("dynamic", nil)

            menu.show(function (options)
                profile = gj_menu.recoverProfile()

                if profile then
                    gj.connect_user(profile.username, profile.token)
                end

                game.set(options.arity, true)
                --game.set(options.mode, true)

                menu.reset()
            end)
        end,
        draw       = menu.draw,
        keypressed = function (key)
            if (key == "escape") then
                love.event.quit()
            end

            menu.keypressed(key)
        end,
        update     = menu.update
    })

    state_machine.addState({
        name       = "gamejolt",
        init       = function ()
            game.set("gamejolt", nil)
            gj_menu.show(function (options)
                profile = gj_menu.recoverProfile()

                if profile then
                    gj.connect_user(profile.username, profile.token)
                end
                -- NOP
            end)
        end,
        draw       = gj_menu.draw,
        keypressed = gj_menu.keypressed,
        update     = gj_menu.update,
        textinput  = gj_menu.textinput
    })

    state_machine.addState({
        name       = "win",
        init       = function ()
            local winner = game.getWinner()

            if player2 then
                player.setShowPath(true)
                player2.setShowPath(true)
            end

            -- TODO find a better way to incorporate the stripe
            --score_band.addStripe(winner.getColor())

            -- talk to GameJolt
            diff = score_band.getDifference()
            gj.add_score(diff, diff * 100)

            victory_message = winner.getMessage()
        end,
        update = function (dt)
            local winner = game.getWinner()
            local loser  = game.getLoser()

            game.updateScore(dt)
            player.updateScore(dt)

            if game.isAlone() then
                results         = score_band.getFormattedDiff()
            else
                results         = score_band.getResults(winner, loser)
            end

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


    local top_string_x    = 0
    local bottom_string_x = 0
    local timer           = 0

    state_machine.addState({
        name = "new_challenger",
        init = function ()
            top_string_x    = -W_WIDTH
            bottom_string_x = W_WIDTH
            timer           = 0
            game.playTogether()
        end,
        draw = function ()
            love.graphics.setFont(SPACE_FONT)
            love.graphics.printf("HERE COMES A", top_string_x, W_HEIGHT / 2 - global.tile_size * 5.5, W_WIDTH, "center")
            love.graphics.printf("NEW CHALLENGER!", bottom_string_x, W_HEIGHT / 2, W_WIDTH, "center")
        end,
        update = function (dt)
            timer = timer + dt
            local step = dt*1500

            if top_string_x < -10 then
                top_string_x = top_string_x + step
            end

            if bottom_string_x > 10 then
                bottom_string_x = bottom_string_x - step
            end
        end
    })

    -- start the game when the player chooses a menu option
    state_machine.addTransition({
        from      = "start",
        to        = "run",
        condition = function ()
            return not menu.isShowing() and not game.get("gamejolt")
        end
    })

    state_machine.addTransition({
        from      = "start",
        to        = "gamejolt",
        condition = function ()
            return game.get("gamejolt")
        end
    })

    state_machine.addTransition({
        from      = "gamejolt",
        to        = "start",
        condition = function ()

            return state_machine.isSet("escape") or not gj_menu.isShowing()
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

    -- restart the game if the player presses space
    state_machine.addTransition({
        from      = "run",
        to        = "run",
        condition = function ()
            return game.getWinner() == nil and game.isAlone() and state_machine.isSet(" ")
        end
    })

    -- return to the menu screen if any player presses escape
    state_machine.addTransition({
        from      = "run",
        to        = "start",
        condition = function ()
            return game.getWinner() == nil and state_machine.isSet("escape")
        end
    })

    -- restart the game if the player presses space
    state_machine.addTransition({
        from      = "win",
        to        = "run",
        condition = function ()
            return state_machine.isSet(" ") or state_machine.isSet("return")
        end
    })

    state_machine.addTransition({
        from      = "new_challenger",
        to        = "run",
        condition = function ()
            return timer > 3
        end
    })

    state_machine.addTransition({
        from      = "run",
        to        = "new_challenger",
        condition = function ()
            return game.isAlone() and state_machine.isSet("return")
        end
    })

    love.update     = state_machine.update
    love.keypressed = state_machine.keypressed
    love.textinput  = state_machine.textinput
    love.draw       = state_machine.draw

    state_machine.start()
end


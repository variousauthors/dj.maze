
-- USEAGE
--
--  state_machine = FSM()

--  -- a state will inherit any method it did not
--  -- declare from the previous state
--  state_machine.addStates({
    --  {
    --      name       = "start",
    --      init       = function () end,
    --      draw       = function () end,
    --      update     = function () end,
    --      keypressed = function () end
    --  }, {
    --      name       = "stop",
    --      init       = function () end,
    --      draw       = function () end,
    --      update     = function () end,
    --      keypressed = function () end
    --  }
--  })

--  state_machine.addTransitions({
    --  {
    --      from = "start",
    --      to = "run",
    --      condition = function ()
    --          return true
    --      end
    --  }
--  })

FSM = function ()
    local states        = {}
    local current_state = { name = "nil" }

    local transitionTo = function (next_state)
        inspect({ from = current_state.name, to = next_state })
        current_state = states[next_state]

        current_state.variables = {}
        if current_state.init then current_state.init() end
    end

    local update = function (dt)
        if current_state.update then current_state.update(dt) end

        -- iterate over the transitions for the current state
        local next_state = {}

        for i, transition in ipairs(current_state.transitions) do
            if transition.condition() then
                table.insert(next_state, transition.to)
            end
        end

        if #next_state == 1 then
            transitionTo(unpack(next_state))
        elseif #next_state > 1 then
            print("AMBIGUITY!")
            inspect(next_state)
            -- exception!
            -- ambiguous state transition
        end
    end

    local draw = function ()
        if current_state.draw then current_state.draw() end
    end

    local keypressed = function (key)
        if (key == "escape") then
            love.event.quit()
        end

        -- transition to draw or win
        if (key == " ") then
            state_machine.set(key)

        --  -- if the player has given up prematurely, they lose
        --  if (winner == nil) then
        --      winner = maze.lose()
        --      score_band.addStripe(winner.getColor())
        --      victory_message = "Dream Big!"
        --      results = ""
        --  else
        --      init()
        --  end
        end

        if current_state.keypressed then current_state.keypressed(key) end
    end

    local addState = function(state)
        states[state.name] = {
            name        = state.name,
            init        = state.init,
            update      = state.update,
            draw        = state.draw,
            keypressed  = state.keypressed,
            transitions = {},
            variables   = {}
        }

        return self
    end

    local addTransition = function(transition)
        table.insert(states[transition.from].transitions, {
            to        = transition.to,
            condition = transition.condition
        })
    end

    local start = function ()
        transitionTo("start")
    end

    local set = function (key)
        current_state.variables[key] = true
    end

    local isSet = function (key)
        local result = false

        if current_state.variables[key] ~= nil then
            result = current_state.variables[key]
        end

        return result
    end

    return {
        start         = start,
        update        = update,
        keypressed    = keypressed,
        draw          = draw,
        addState      = addState,
        addTransition = addTransition,
        set           = set,
        isSet         = isSet
    }
end


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
    local states = {}
    local current_state = {}

    local transitionTo = function (next_state)
        current_state = states[next_state]

        current_state.init()

        love.draw       = current_state.draw
        love.keypressed = current_state.keypressed
    end

    local update = function (dt)
        current_state.update(dt)

        -- iterate over the transitions for the current state
        local next_state = {}

        for k, transition in pairs(current_state.transitions) do
            if transition.condition() then
                table.insert(next_state, transition.to)
            end
        end

        if #next_state == 1 then
            print("hellooo")
            transitionTo(current_state)
        elseif #next_state > 1 then
            -- exception!
            -- ambiguous state transition
        end
    end

    local addState = function(state)
        states[state.name] = {
            init        = state.init,
            update      = state.update,
            draw        = state.draw,
            keypressed  = state.keypressed,
            transitions = {}
        }

        return self
    end

    local addTransition = function(transition)
        states[transition.from].transitions = {
            to        = transition.to,
            condition = transition.condition
        }
    end

    local start = function ()
        transitionTo("start")
    end

    return {
        start         = start,
        update        = update,
        addState      = addState,
        addTransition = addTransition
    }
end

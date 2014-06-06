
state_machine = FSM()

-- a state will inherit any method it did not
-- declare from the previous state
state_machine.addStates({
    name       = "start",
    init       = function () end,
    draw       = function () end,
    update     = function () end,
    keypressed = function () end
}, {
    name       = "stop",
    init       = function () end,
    draw       = function () end,
    update     = function () end,
    keypressed = function () end
})

state_machine.addTransitions({
    from = "start",
    to = "run",
    condition = function ()
        return true
    end
})

FSM = function ()
    local states, transitions = {}, {}

    local update = function ()
        -- iterate over the transitions for the current state

        for k, transition in pairs(current_state.transitions) do
            if transition.condition() then
                table.insert(next_state, transition.to)
            end
        end

        if #next_state == 1 then
            current_state = states[next_state]
            current_state.init()
        else
            -- exception!
            -- ambiguous state transition
        end
    end

    local addState = function(state)
        states[state.name] = {
            init       = state.init,
            update     = state.update,
            draw       = state.draw,
            keypressed = state.keypressed,
        }
    end

    local addTransition = function(transition)
        state[transition.from] = {
            to        = transition.to,
            condition = transition.condition
        }
    end

    local addStates = function (options)
        for k, v in pairs(options) do

            addState(v)
        end
    end

    local addTransitions = function (options)
        for k, v in pairs(options) do

            addTransition(v)
        end
    end

    return {
        update             = update,
        addStates          = addStates
        addStateTransition = addStateTransitions
    }
end

input = {}
input.held = {}
input.axis = {horizontal = 0, vertical = 0, dpadHorizontal = 0, dpadVertical = 0}
input.flipYAxis = true

function input.updateInputs(dt)
    for i = 1, #input.held do
        inputs.held[i].time = inputs.held[i].time + dt
    end

    input.updateAxis()
end

function input.updatePressed(button)
    table.insert(input.held, {button=button, time=0})
end

function input.updateReleased(button)
    if level.displayed and button then
        for i = 1, #inputs.held do
            if inputs.held[i] ~= nil and inputs.held[i].button ~= nil and inputs.held[i].button == button then
                table.remove(inputs.held, i)
            end
        end
    end
end

function input.updateAxis()

    if input.flipYAxis then
        modifier = -1
    else
        modifier = 1
    end

    input.axis.dpadHorizontal = 0

    if input.buttonHeld("dpright") then
        input.axis.dpadHorizontal = input.axis.dpadHorizontal + 1
    elseif input.buttonHeld("dpleft") then
        input.axis.dpadHorizontal = input.axis.dpadHorizontal - 1
    end

    input.axis.dpadVertical = 0

    if input.buttonHeld("dpup") then
        input.axis.dpadVertical = input.axis.dpadVertical + 1 * modifier
    elseif input.buttonHeld("dpdown") then
        input.axis.dpadVertical = input.axis.dpadVertical - 1 * modifier
    end


end

function input.buttonHeld(button)
    for i = 1, #input.held do
        if input.held[i].button == button then
            return true
        end
    end
    return false
end


console = {}
console.enabled = true
console.offestX = 10
console.offestY = 10
console.margin = 5
console.lastPrint = 0
console.fontHeight = love.graphics.getFont():getHeight()
console.previousPrints = {}

-- Console Funcs
function console.log(message)
    table.insert(console.previousPrints, tostring(message))
    print(tostring(message))
end

function console.displayLogs()
    console.lastPrint = 0
    for i=1, #console.previousPrints do
        love.graphics.print(tostring(console.previousPrints[i]), console.offestX, console.offestY + console.lastPrint)
        console.lastPrint = console.lastPrint + console.fontHeight + console.margin
        if (console.lastPrint > love.graphics.getHeight()) then
            console.previousPrints = {}
            console.lastPrint = 0
        end
    end
end
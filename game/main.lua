function love.load()
    math.randomseed( os.time() )

    background = {R = 0.078, G = 0.078, B = 0.078, A = 1}

    font = love.graphics.newFont(20)
    completedFont = love.graphics.newFont(50)
    smallFont = love.graphics.newFont(15)

    love.graphics.setFont(font);

    console = {}
    console.enabled = true
    console.offestX = 10
    console.offestY = 10
    console.margin = 5
    console.lastPrint = 0
    console.fontHeight = love.graphics.getFont():getHeight()
    console.previousPrints = {}

    level = {}
    level.width = 5
    level.height = 5
    level.cellSize = love.graphics.getHeight() / level.height
    level.xOffset = (love.graphics.getWidth() / 2) - (level.width/2 * level.cellSize)
    level.grid = {}
    level.lockedAmmount = 15
    level.shuffleItterations = 2
    level.lockedTiles = {}
    level.solution = {}
    level.completed = false
    level.completedTimer = 0
    level.completedTime = 2

    level.startTimer = 0
    level.startTime = 0.4

    selected = {}
    selected.x = 0
    selected.y = 0

    pointer = {}
    pointer.x = 0
    pointer.y = 0
    pointer.shown = false

    gameDisplayed = false
    menuDisplayed = true

    menu = {}
    menu.selected = 0
    menu.highest = 4
    menu.margin = 10

    inputs = {}
    inputs.held = {}
    inputs.timer = 0
    inputs.time = 0.1
    inputs.buttonTime = 0.2
end

function love.update(dt)
    if level.completed then
        level.completedTimer = level.completedTimer + dt
    end
    if level.startTimer < level.startTime then
        level.startTimer = level.startTimer + dt
    else
        level.startTimer = level.startTime
    end

    inputs.timer = inputs.timer + dt

    for i = 1, #inputs.held do
        inputs.held[i].time = inputs.held[i].time - dt
    end

    if inputs.timer > inputs.time then
        for i = 1, #inputs.held do
            if inputs.held[i].button == "dpup" and selected.y > 0 and inputs.held[i].time < 0 then
                selected.y = selected.y - 1
            elseif inputs.held[i].button == "dpdown" and selected.y < level.height-1 and inputs.held[i].time < 0 then
                selected.y = selected.y + 1
            elseif inputs.held[i].button == "dpleft" and selected.x > 0 and inputs.held[i].time < 0 then
                selected.x = selected.x - 1
            elseif inputs.held[i].button == "dpright" and selected.x < level.width-1 and inputs.held[i].time < 0 then
                selected.x = selected.x + 1
            end
        end
        inputs.timer = 0
    end
end

function love.draw()
    --drawing background
    love.graphics.setColor(background.R, background.G, background.B, background.A)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    if menuDisplayed then
        love.graphics.setColor(1,1,1,1)
        love.graphics.printf("New Game", 5, 5, love.graphics.getWidth())

        spacing = 20

        love.graphics.printf("Width: " .. level.width, 0, (love.graphics.getHeight()/3) + font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.printf("Height: " .. level.height, 0, (love.graphics.getHeight()/3) + spacing * 2 + font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.printf("Locked tiles: " .. level.lockedAmmount, 0, (love.graphics.getHeight()/3) + spacing*4 + font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.printf("Play", 0, (love.graphics.getHeight()/3) + spacing*6 + font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.printf("Quit", 0, (love.graphics.getHeight()/3) + spacing*8 + font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.setFont(smallFont)

        love.graphics.print("press + to return to the menu, and press - to generate a new level.", menu.margin, love.graphics.getHeight() - menu.margin - smallFont:getHeight())
        
        love.graphics.setFont(font)

        --slector
        love.graphics.circle("line", love.graphics.getWidth() / 2 - 100, (love.graphics.getHeight()/3) + font:getHeight() + spacing * 2 * menu.selected + font:getHeight()/2, 5)
    end

    if gameDisplayed then
        --drawing level
        drawLevel()

        drawLockDots()

        --drawing selector
        love.graphics.setColor(1,1,1,0.5)
        love.graphics.rectangle("line", selected.x*level.cellSize + level.xOffset, selected.y*level.cellSize, level.cellSize, level.cellSize)

        --drawing pointer
        if pointer.shown then
            love.graphics.setColor(1,0,0,0.5)
            love.graphics.rectangle("line", pointer.x*level.cellSize + level.xOffset, pointer.y*level.cellSize, level.cellSize, level.cellSize)
        end

        if level.completed then
            love.graphics.setFont(completedFont);

            love.graphics.setColor(0,0,0,level.completedTimer / level.completedTime)
            love.graphics.printf("Completed!", 0, love.graphics.getHeight()/2 - completedFont:getHeight(), love.graphics.getWidth(), "center")

            love.graphics.setFont(font);

            love.graphics.printf("press any key to go back to the menu.", 0, love.graphics.getHeight()/2 + completedFont:getHeight(), love.graphics.getWidth(), "center")


        end
    end

    --Display Console Messages
    if console.enabled then
        displayLogs()
    end
end

function love.gamepadpressed(joystick, button)
    if gameDisplayed then
        if level.completed and level.completedTimer > level.completedTime then
            gameDisplayed = false
            menuDisplayed = true

            menu.selected = 0

            return
        end

        if button == "dpup" and selected.y > 0 then
            selected.y = selected.y - 1
            table.insert(inputs.held, {button=button, time=inputs.buttonTime})
        elseif button == "dpdown" and selected.y < level.height-1 then
            selected.y = selected.y + 1
            table.insert(inputs.held, {button=button, time=inputs.buttonTime})
        elseif button == "dpleft" and selected.x > 0 then
            selected.x = selected.x - 1
            table.insert(inputs.held, {button=button, time=inputs.buttonTime})
        elseif button == "dpright" and selected.x < level.width-1 then
            selected.x = selected.x + 1
            table.insert(inputs.held, {button=button, time=inputs.buttonTime})
        elseif button == "back" then
            initLevel()
        elseif button == "a" or button == "b" then
            if pointer.shown then
                if not lockedTilesContains(selected.x, selected.y) then
                    
                    point = level.grid[selected.x+1][selected.y+1]

                    level.grid[selected.x+1][selected.y+1] = level.grid[pointer.x+1][pointer.y+1]

                    level.grid[pointer.x+1][pointer.y+1] = point

                    pointer.shown = false

                    checkSolution()
                end
            else
                if not lockedTilesContains(selected.x, selected.y) then
                    pointer.shown = true

                    pointer.x = selected.x
                    pointer.y = selected.y
                end
            end
        end

    end

    if menuDisplayed then
        if button == "dpup" and menu.selected > 0 then
            menu.selected = menu.selected - 1
        elseif button == "dpdown" and menu.selected < menu.highest then
            menu.selected = menu.selected + 1
        elseif button == "dpright" or button == "a"then
            if menu.selected == 0 then
                level.width = level.width + 1
            elseif menu.selected == 1 then
                level.height = level.height + 1
            elseif menu.selected == 2 then
                level.lockedAmmount = level.lockedAmmount + 1
            elseif menu.selected == 3 then
                gameDisplayed = true
                menuDisplayed = false

                initLevel()
            elseif menu.selected == 4 then
                love.event.quit()
            end
        elseif button == "dpleft" or button == "b" then
            if menu.selected == 0 then
                level.width = level.width - 1
            elseif menu.selected == 1 then
                level.height = level.height - 1
            elseif menu.selected == 2 then
                level.lockedAmmount = level.lockedAmmount - 1
            elseif menu.selected == 3 then
                gameDisplayed = true
                menuDisplayed = false

                initLevel()
            elseif menu.selected == 4 then
                love.event.quit()
            end
        end
    end

    if button == "start" then
        gameDisplayed = false
        menuDisplayed = true
    end
    if button == "back" then
        console.enabled = not console.enabled
    end
end

function love.gamepadreleased(joystick, button)
    if gameDisplayed and button then
        for i = 1, #inputs.held do
            if inputs.held[i] ~= nil and inputs.held[i].button ~= nil and inputs.held[i].button == button then
                table.remove(inputs.held, i)
            end
        end
    end
end

--level funcs
function drawLevel()
    for x = 0, level.width-1 do
        for y = 0, level.height-1 do
            cell = level.grid[x+1][y+1]

            love.graphics.setColor(cell.R,cell.G,cell.B,cell.A)
            drawCenteredRect(
                "fill", 
                x*level.cellSize - level.cellSize / 2 + level.xOffset, 
                y*level.cellSize - level.cellSize / 2, 
                level.cellSize * (level.startTimer/level.startTime), 
                level.cellSize * (level.startTimer/level.startTime)
            )
        end
    end
end

function drawLockDots()
    love.graphics.setColor(0,0,0,1)
    for i = 1, #level.lockedTiles do
        love.graphics.circle("fill", level.lockedTiles[i].x*level.cellSize + level.xOffset + level.cellSize/2  * (level.startTimer/level.startTime), 
        level.lockedTiles[i].y * level.cellSize + level.cellSize/2  * (level.startTimer/level.startTime), 
        5)
    end
end

function genorateLockedTile() 
    randX = math.random(0, level.width-1)
    randY = math.random(0, level.height-1)

    --check if tile is already locked
    valid = not lockedTilesContains(randX, randY)

    if valid then
        table.insert(level.lockedTiles, {x=randX, y=randY})
    else
        genorateLockedTile()
    end
end

function lockedTilesContains(x, y)
    contains = false
    for v = 1, #level.lockedTiles do
        if level.lockedTiles[v].x == x and level.lockedTiles[v].y == y then
            contains = true
        end
    end
    return contains
end

function checkSolution()
    if table.equals(level.grid, level.solution) then
        level.completed = true
    end
end

function initLevel()

    level.completed = false

    if level.lockedAmmount >= level.height * level.width then
        level.lockedAmmount = level.height * level.width
        level.completed = true
    end

    level.cellSize = love.graphics.getHeight() / level.height
    level.xOffset = (love.graphics.getWidth() / 2) - (level.width/2 * level.cellSize)
    level.grid = {}
    level.lockedTiles = {}
    level.solution = {}

    level.completedTimer = 0

    level.startTimer = 0


    selected.x = 0
    selected.y = 0

    pointer.x = 0
    pointer.y = 0
    pointer.shown = false

    --Result = (color2 - color1) * fraction + color1
    color1 = {R = math.random(), G = math.random(), B = math.random()}
    color2 = {R = math.random(), G = math.random(), B = math.random()}

    difference = (color1.R - color2.R)^2 + (color1.G - color2.G)^2 + (color1.B - color2.B)^2

    offset = {X=math.random(0,5), Y=math.random(0,5)}

    if difference < 0.2 then
        initLevel()
        return
    end

    --genorate level
    for x = 0, level.width-1 do
        temp = {}
        for y = 0, level.height-1 do
            table.insert(temp, {
                R = (color1.R - color2.R) * ((x / level.width + y / level.height)/2) + color1.R,
                G = (color1.G - color2.G) * ((x / level.width + y / level.height)/2) + color1.G, 
                B = (color1.B - color2.B) * ((x / level.width + y / level.height)/2) + color1.B, 
            })
        end
        table.insert(level.grid, temp)
    end

    level.solution = table.clone(level.grid)

    --select locked lockedTiles
    for i = 1, level.lockedAmmount do
        genorateLockedTile()
    end

    --shuffle level
    for i = 1, level.shuffleItterations do
        for x = 1, #level.grid do
            for y = 1, #level.grid[x] do

                randX = math.random(1, level.width)
                randY = math.random(1, level.height)

                --check if locked
                valid = not (lockedTilesContains(randX-1, randY-1) or lockedTilesContains(x-1, y-1))

                if valid then
                    --swap the tiles
                    temp = level.grid[x][y]
                    level.grid[x][y] = level.grid[randX][randY]
                    level.grid[randX][randY] = temp
                end

            end
        end
    end

    if table.equals(level.grid, level.solution) then
        initLevel()
    end
end

function drawCenteredRect(displayType, x,y,width,height)
    love.graphics.rectangle(displayType, x+width/2, y+height/2, width, height)
end

-- Console Funcs
function log(message)
    table.insert(console.previousPrints, tostring(message))
    print(tostring(message))
end

function displayLogs()
    console.lastPrint = 0
    for i=1, #console.previousPrints do
        love.graphics.print(console.previousPrints[i], console.offestX, console.offestY + console.lastPrint)
        console.lastPrint = console.lastPrint + console.fontHeight + console.margin
        if (console.lastPrint > love.graphics.getHeight()) then
            console.previousPrints = {}
            console.lastPrint = 0
        end
    end
end

--utils
function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} \n'
    else
       return tostring(o)
    end
 end

 function shuffle(x)
	for i = #x, 2, -1 do
		local j = math.random(i)
		x[i], x[j] = x[j], x[i]
	end
end

function table.clone(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[table.clone(orig_key, copies)] = table.clone(orig_value, copies)
            end
            setmetatable(copy, table.clone(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table.equals(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or table.equals(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end

function HSV(h, s, v)
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return r+m, g+m, b+m
end
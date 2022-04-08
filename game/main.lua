function love.load()
    require("utils")
    require("console")
    require("menu")

    math.randomseed( os.time() )

    background = {R = 0.078, G = 0.078, B = 0.078, A = 1}

    font = love.graphics.newFont(20)
    completedFont = love.graphics.newFont(50)
    smallFont = love.graphics.newFont(15)

    love.graphics.setFont(font);

    level = {}

    level.displayed = false

    level.width = 9
    level.height = 5
    level.cellSize = love.graphics.getHeight() / level.height
    level.xOffset = (love.graphics.getWidth() / 2) - (level.width/2 * level.cellSize)
    level.grid = {}
    level.lockedAmmount = 15
    level.shuffleItterations = 5
    level.lockedTiles = {}
    level.solution = {}
    level.completed = false
    level.completedTimer = 0
    level.completedTime = 2

    level.startTimer = 0
    level.startTime = 0.6

    selected = {}
    selected.x = 0
    selected.y = 0
    selected.shown = true

    pointer = {}
    pointer.x = 0
    pointer.y = 0
    pointer.shown = false

    inputs = {}
    inputs.held = {}
    inputs.time = 0.1
    inputs.buttonTime = 0.2

    touches = {}

    initLevel()
end

function love.update(dt)

    menu.upadeMenu(dt)

    if level.completed then
        level.completedTimer = level.completedTimer + dt
    end
    if level.startTimer < level.startTime then
        level.startTimer = level.startTimer + dt
    else
        level.startTimer = level.startTime
    end

    for i = 1, #inputs.held do
        inputs.held[i].time = inputs.held[i].time - dt
        if inputs.held[i].time < 0 then
            if inputs.held[i].button == "dpup" and selected.y > 0 then
                selected.y = selected.y - 1
            elseif inputs.held[i].button == "dpdown" and selected.y < level.height-1 then
                selected.y = selected.y + 1
            elseif inputs.held[i].button == "dpleft" and selected.x > 0 then
                selected.x = selected.x - 1
            elseif inputs.held[i].button == "dpright" and selected.x < level.width-1 then
                selected.x = selected.x + 1
            end

            inputs.held[i].time = inputs.time
        end
    end
end

function love.touchpressed( id, x, y, dx, dy, pressure )
    if menu.displayed then
        if menu.startShown then
            menu.startShown = false
            menu.coustomShown= true
        end
    elseif level.displayed then

        selected.shown = false

        if level.completed and level.completedTimer > level.completedTime / 2 then
            level.displayed = false
            menu.displayed = true

            menu.selected = 0

            return
        end

        tileX = math.floor((x-level.xOffset)/level.cellSize) + 1
        tileY = math.floor(y/level.cellSize) + 1

        if tileX <= level.width and tileX > 0 and tileY <= level.height and tileY > 0 and level.displayed == true then
            if not isLockedTile(tileX-1, tileY-1) then
                touches[id] = {x=tileX, y=tileY, id=id}

                touchedTile = level.grid[tileX][tileY]

                level.grid[tileX][tileY].visible = false
            end
        end
    end
end

function love.touchreleased( id, x, y, dx, dy, pressure )

    if touches[id] ~= nil then
        firstTileX = touches[id].x
        firstTileY = touches[id].y

        secondTileX = math.floor((x-level.xOffset)/level.cellSize) + 1
        secondTileY = math.floor(y/level.cellSize) + 1

        if secondTileX <= level.width and secondTileX > 0 and secondTileY <= level.height and secondTileY > 0 and level.displayed == true then
            firstTile = level.grid[firstTileX][firstTileY]
            secondTile = level.grid[secondTileX][secondTileY]

            if not isLockedTile(secondTileX-1, secondTileY-1) then
                
                level.grid[firstTileX][firstTileY].visible = true

                point = level.grid[firstTileX][firstTileY]

                level.grid[firstTileX][firstTileY] = level.grid[secondTileX][secondTileY]

                level.grid[secondTileX][secondTileY] = point

                checkSolution()
            end
        end
        level.grid[firstTileX][firstTileY].visible = true
        touches[id] = nil


    end
end

function love.draw()
    --drawing background
    love.graphics.setColor(background.R, background.G, background.B, background.A)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    if menu.displayed then
        menu.drawMenu()
    end

    if level.displayed then
        --drawing level
        drawLevel()

        drawLockDots()

        for k, v in pairs(touches) do
            x, y = love.touch.getPosition( touches[k].id )

            color = level.grid[touches[k].x][touches[k].y]

            love.graphics.setColor(color.R,color.G,color.B, 1)
            drawCenteredRect("fill", x, y, level.cellSize, level.cellSize)
        end

        --drawing selector
        if selected.shown then
            love.graphics.setColor(1,1,1,0.5)
            love.graphics.rectangle("line", selected.x*level.cellSize + level.xOffset, selected.y*level.cellSize, level.cellSize, level.cellSize)
        end

        --drawing pointer
        if pointer.shown and selected.shown then
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
        console.displayLogs()
    end
end


function love.gamepadpressed(joystick, button)
    if level.displayed then
        if level.completed and level.completedTimer > level.completedTime / 2 then
            level.displayed = false
            menu.displayed = true

            menu.selected = 0

            return
        end

        selected.shown = true

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
                if not isLockedTile(selected.x, selected.y) then
                    
                    point = level.grid[selected.x+1][selected.y+1]

                    level.grid[selected.x+1][selected.y+1] = level.grid[pointer.x+1][pointer.y+1]

                    level.grid[pointer.x+1][pointer.y+1] = point

                    pointer.shown = false

                    checkSolution()
                end
            else
                if not isLockedTile(selected.x, selected.y) then
                    pointer.shown = true

                    pointer.x = selected.x
                    pointer.y = selected.y
                end
            end
        end

    end

    if menu.displayed then
        if menu.startShown then
            if button == "start" then
                love.event.quit()
            else
                menu.startShown = false
                menu.coustomShown= true
            end
        else
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
                    level.displayed = true
                    menu.displayed = false

                    initLevel()
                elseif menu.selected == 4 then
                    menu.coustomShown = false
                    menu.startShown = true
                end
            elseif button == "dpleft" or button == "b" then
                if menu.selected == 0 then
                    level.width = level.width - 1
                elseif menu.selected == 1 then
                    level.height = level.height - 1
                elseif menu.selected == 2 then
                    level.lockedAmmount = level.lockedAmmount - 1
                elseif menu.selected == 3 then
                    level.displayed = true
                    menu.displayed = false

                    initLevel()
                elseif menu.selected == 4 then
                    menu.coustomShown = false
                    menu.startShown = true
                end
            end
        end
    end

    if button == "start" then
        level.displayed = false
        menu.displayed = true
    end
    if button == "back" then
        console.enabled = not console.enabled
    end
end

function love.gamepadreleased(joystick, button)
    if level.displayed and button then
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
            if cell.visible then
                love.graphics.setColor(cell.R,cell.G,cell.B,cell.A)
                drawCenteredRect(
                    "fill", 
                    x*level.cellSize + level.cellSize / 2 + level.xOffset, 
                    y*level.cellSize + level.cellSize / 2, 
                    level.cellSize * (level.startTimer/level.startTime), 
                    level.cellSize * (level.startTimer/level.startTime)
                )
            end
        end
    end
end

function drawLockDots()
    love.graphics.setColor(0,0,0,1)
    for i = 1, #level.lockedTiles do
        love.graphics.circle("fill", level.lockedTiles[i].x*level.cellSize + level.xOffset + level.cellSize/2, 
        level.lockedTiles[i].y * level.cellSize + level.cellSize/2, 
        6)
    end
end

function genorateLockedTile() 
    randX = math.random(0, level.width-1)
    randY = math.random(0, level.height-1)

    --check if tile is already locked
    valid = not isLockedTile(randX, randY)

    if valid then
        table.insert(level.lockedTiles, {x=randX, y=randY})
    else
        genorateLockedTile()
    end
end

function isLockedTile(x, y)
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

    circlePos = math.random()
    circlePos2 = circlePos + 0.5

    if circlePos2 > 1 then
        circlePos2 = circlePos2 - 1
    end

    color1 = HSV(circlePos,0.8,1)
    color2 = HSV(circlePos2,1,0.5)

    topLeftHue = math.random()
    topRightHue = math.random()
    bottomLeftHue = math.random()
    bottomRightHue = math.random()

    colors = {}
    colors.topLeft = HSV(topLeftHue, math.random(), 1)
    colors.topRight = HSV(topRightHue, math.random(), 1)
    colors.bottomLeft = HSV(bottomLeftHue, math.random(), 1)
    colors.bottomRight = HSV(topRightHue, math.random(), 1)

    --genorate level
    for x = 0, level.width-1 do
        temp = {}
        for y = 0, level.height-1 do

            xPercent = x/level.width
            yPercent = y/level.height

            

            
            --biliniar interpolation
            topColor = interpolateColor(colors.topLeft, colors.topRight, xPercent)
            bottomColor = interpolateColor(colors.bottomLeft, colors.bottomRight, xPercent)
            color = interpolateColor(topColor, bottomColor, yPercent)

            color.visible = true

            table.insert(temp, color)
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
                valid = not (isLockedTile(randX-1, randY-1) or isLockedTile(x-1, y-1))

                if valid then
                    --swap the tiles
                    temp = level.grid[x][y]
                    level.grid[x][y] = level.grid[randX][randY]
                    level.grid[randX][randY] = temp
                end

            end
        end
    end

    if table.equals(level.grid, level.solution) and not level.completed then
        initLevel()
    end
end

function drawCenteredRect(displayType, x,y,width,height)
    love.graphics.rectangle(displayType, x-width/2, y-height/2, width, height)
end
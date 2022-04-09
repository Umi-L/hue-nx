menu = {}
menu.selected = 0
menu.highest = 4
menu.margin = 10
menu.displayed = true
menu.titleFont = love.graphics.newFont(50)
menu.titleFade = 0
menu.titleFadeTime = 2
menu.tileHight = 5
menu.tileSize = love.graphics.getHeight() / menu.tileHight
menu.tileWidth = math.ceil(love.graphics.getWidth() / menu.tileSize)
menu.chromaSpeed = 0.1
menu.customShown = false
menu.startShown = true
menu.levelSelectShown = false
menu.buttonColor = newColor(76/255, 68/255, 81/255)
menu.levelSelectButtons = {
    {
        x=love.graphics.getWidth()/8, 
        y=love.graphics.getHeight()/5*4, 
        width=love.graphics.getWidth()/5, 
        height=love.graphics.getHeight()/7,
        rounding = 2,
        color = menu.buttonColor,
        text="Easy"
    },

    {
        x=love.graphics.getWidth()/8*3, 
        y=love.graphics.getHeight()/5*4, 
        width=love.graphics.getWidth()/5, 
        height=love.graphics.getHeight()/7,
        rounding = 2,
        color = menu.buttonColor,
        text="Medium"
    },

    {
        x=love.graphics.getWidth()/8*5, 
        y=love.graphics.getHeight()/5*4, 
        width=love.graphics.getWidth()/5, 
        height=love.graphics.getHeight()/7,
        rounding = 2,
        color = menu.buttonColor,
        text="Hard"
    },

    {
        x=love.graphics.getWidth()/8*7, 
        y=love.graphics.getHeight()/5*4, 
        width=love.graphics.getWidth()/5, 
        height=love.graphics.getHeight()/7,
        rounding = 2,
        color = menu.buttonColor,
        text="Custom"
    },
}

menu.colors = {
    newColor(1,0,1), 
    newColor(1,0.3,1),
    newColor(1,0.4,0.1), 
    newColor(1,1,0.1)
}

function menu.drawMenu()
    for y = 0, menu.tileHight-1 do
        for x = 0, menu.tileWidth-1 do

            xPercent = x/menu.tileHight
            yPercent = y/menu.tileWidth
            
            --biliniar interpolation
            topColor = interpolateColor(menu.colors[1], menu.colors[2], xPercent)
            bottomColor = interpolateColor(menu.colors[3], menu.colors[4], xPercent)
            color = interpolateColor(topColor, bottomColor, yPercent)

            drawTile(x,y,color)
        end
    end
    if menu.startShown then
        love.graphics.setColor(0,0,0,menu.titleFade / menu.titleFadeTime)
        love.graphics.setFont(menu.titleFont)
        love.graphics.printf("Hue", 0, love.graphics.getHeight()/3, love.graphics.getWidth(), "center")

        love.graphics.setFont(font)
        love.graphics.printf("Press any button to start.", 0, love.graphics.getHeight()/3*2, love.graphics.getWidth(), "center")
        love.graphics.printf("Press + to quit", 0, love.graphics.getHeight()/3*2 + menu.margin+font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.setFont(smallFont)
        love.graphics.print("press + to return to the menu, and press - re-genorate the level.", menu.margin, love.graphics.getHeight() - menu.margin - smallFont:getHeight())
    elseif menu.customShown then
        love.graphics.setColor(0,0,0,1)
        love.graphics.printf("Coustom level", 5, 5, love.graphics.getWidth())

        spacing = 20

        love.graphics.printf("Width: " .. level.width, 0, (love.graphics.getHeight()/3) + font:getHeight(), love.graphics.getWidth(), "center")
        love.graphics.printf("Height: " .. level.height, 0, (love.graphics.getHeight()/3) + spacing * 2 + font:getHeight(), love.graphics.getWidth(), "center")
        love.graphics.printf("Locked tiles: " .. level.lockedAmmount, 0, (love.graphics.getHeight()/3) + spacing*4 + font:getHeight(), love.graphics.getWidth(), "center")
        love.graphics.printf("Play", 0, (love.graphics.getHeight()/3) + spacing*6 + font:getHeight(), love.graphics.getWidth(), "center")
        love.graphics.printf("Back", 0, (love.graphics.getHeight()/3) + spacing*8 + font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.setFont(smallFont)
        love.graphics.print("press + to return to the menu, and press - re-genorate the level.", menu.margin, love.graphics.getHeight() - menu.margin - smallFont:getHeight())
        love.graphics.setFont(font)

        --slector
        love.graphics.circle("line", love.graphics.getWidth() / 2 - 100, (love.graphics.getHeight()/3) + font:getHeight() + spacing * 2 * menu.selected + font:getHeight()/2, 5)
    
    elseif menu.levelSelectShown then
        love.graphics.setFont(menu.titleFont)
        love.graphics.setColor(0,0,0,1)
        love.graphics.printf("New Game", 0, love.graphics.getHeight()/4, love.graphics.getWidth(), "center")

        love.graphics.setFont(smallFont)
        love.graphics.print("press + to return to the menu, and press - re-genorate the level.", menu.margin, love.graphics.getHeight() - menu.margin - smallFont:getHeight())
        love.graphics.setFont(font)

        for i = 1, #menu.levelSelectButtons do
            local button = menu.levelSelectButtons[i]
            local c = button.color

            love.graphics.setColor(c.R, c.G, c.B)
            love.graphics.rectangle("fill", button.x - button.width/2, button.y - button.height/2,  button.width, button.height, button.rounding, button.rounding)

            love.graphics.setFont(font)
            love.graphics.setColor(1,1,1,1)
            love.graphics.printf(button.text, button.x - button.width/2, button.y - font:getHeight()/2, button.width, "center")
        end
    end
end

function menu.upadeMenu(dt)
    menu.titleFade = menu.titleFade + dt
    if menu.titleFade > menu.titleFadeTime then
        menu.titleFade = menu.titleFadeTime
    end
end

function drawTile(x,y,color)
    love.graphics.setColor(color.R, color.G, color.B)
    love.graphics.rectangle("fill", x*menu.tileSize, y*menu.tileSize, menu.tileSize, menu.tileSize)
end
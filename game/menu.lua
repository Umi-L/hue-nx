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
menu.coustomShown = false
menu.startShown = true

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
    if not menu.coustomShown then
        love.graphics.setColor(0,0,0,menu.titleFade / menu.titleFadeTime)
        love.graphics.setFont(menu.titleFont)
        love.graphics.printf("Hue", 0, love.graphics.getHeight()/3, love.graphics.getWidth(), "center")

        love.graphics.setFont(font)
        love.graphics.printf("Press any button to start.", 0, love.graphics.getHeight()/3*2, love.graphics.getWidth(), "center")
        love.graphics.printf("Press + to quit", 0, love.graphics.getHeight()/3*2 + menu.margin+font:getHeight(), love.graphics.getWidth(), "center")

        love.graphics.setFont(smallFont)
        love.graphics.print("press + to return to the menu, and press - re-genorate the level.", menu.margin, love.graphics.getHeight() - menu.margin - smallFont:getHeight())
    else
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
    
    end
end

function menu.upadeMenu(dt)
        
    print(dump(menu.colors))


    menu.titleFade = menu.titleFade + dt
    if menu.titleFade > menu.titleFadeTime then
        menu.titleFade = menu.titleFadeTime
    end
end

function drawTile(x,y,color)
    love.graphics.setColor(color.R, color.G, color.B)
    love.graphics.rectangle("fill", x*menu.tileSize, y*menu.tileSize, menu.tileSize, menu.tileSize)
end
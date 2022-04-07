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

menu.colors = {
    HSV(math.random(), math.random() + 0.5, 1), 
    HSV(math.random(), math.random() + 0.5, 1), 
    HSV(math.random(), math.random() + 0.5, 1), 
    HSV(math.random(), math.random() + 0.5, 1) 
}
-- menu.colors.topLeft = HSV(math.random(), math.random() + 0.5, 1)
-- menu.colors.topRight = HSV(math.random(), math.random() + 0.5, 1)
-- menu.colors.bottomLeft = HSV(math.random(), math.random() + 0.5, 1)
-- menu.colors.bottomRight = HSV(math.random(), math.random() + 0.5, 1)


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

    -- love.graphics.setColor(background.R, background.G, background.B, )
    -- love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    love.graphics.setColor(0,0,0,menu.titleFade / menu.titleFadeTime)
    love.graphics.setFont(menu.titleFont)
    love.graphics.printf("Hue", 0, love.graphics.getHeight()/3, love.graphics.getWidth(), "center")

    love.graphics.setFont(font)
    love.graphics.printf("Press any button to start.", 0, love.graphics.getHeight()/3*2, love.graphics.getWidth(), "center")

    love.graphics.setFont(smallFont)
    love.graphics.print("press + to return to the menu, and press - re-genorate the level.", menu.margin, love.graphics.getHeight() - menu.margin - smallFont:getHeight())

end

function menu.upadeMenu(dt)
    for i = 1, #menu.colors do
        

        menu.colors[i].R = menu.colors[i].R + 1
        menu.colors[i].R = menu.colors[i].R + 1

    end

    menu.titleFade = menu.titleFade + dt
    if menu.titleFade > menu.titleFadeTime then
        menu.titleFade = menu.titleFadeTime
    end
end

function drawTile(x,y,color)
    love.graphics.setColor(color.R, color.G, color.B)
    love.graphics.rectangle("fill", x*menu.tileSize, y*menu.tileSize, menu.tileSize, menu.tileSize)
end
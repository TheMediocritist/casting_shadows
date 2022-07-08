import 'CoreLibs/graphics'

local gfx = playdate.graphics
local geom = playdate.geometry

local input_vector = playdate.geometry.vector2D.new(0, 0)

playdate.display.setRefreshRate(50)
gfx.setColor(gfx.kColorBlack)

local obstacles = {}
obstacles[#obstacles + 1] = {type = 'rect', height = 8, geom = geom.polygon.new(0, 60, 120, 60, 120, 80, 0, 80, 0, 60)}
obstacles[#obstacles + 1] = {type = 'rect', height = 3, geom = geom.polygon.new(100, 100, 120, 100, 120, 120, 100, 120, 100, 100)}
obstacles[#obstacles + 1] = {type = 'rect', height = 25, geom = geom.polygon.new(200, 40, 220, 40, 220, 80, 200, 80, 200, 40)}
obstacles[#obstacles + 1] = {type = 'rect', height = 10, geom = geom.polygon.new(100, 200, 120, 200, 120, 220, 100, 220, 100, 200)}
obstacles[#obstacles + 1] = {type = 'rect', height = 15, geom = geom.polygon.new(200, 200, 220, 200, 220, 220, 200, 220, 200, 200)}
obstacles[#obstacles + 1] = {type = 'rect', height = 5, geom = geom.polygon.new(160, 140, 180, 140, 180, 1800, 160, 180, 160, 140)}
obstacles[#obstacles + 1] = {type = 'rect', height = 9, geom = geom.polygon.new(200, 200, 220, 200, 220, 220, 200, 220, 200, 200)}
obstacles[#obstacles + 1] = {type = 'circle', height = 13, x = 180, y = 100, diameter = 10}

local player = {}
player.x, player.y = 200, 120
player.direction = 0
player.torch_width = 60
player.light_mask = geom.polygon.new(1)

local shadows = true

function playdate.update()
    
    -- update player position 
    update_player()
    
    
    if shadows == true then
        
        -- clear screen to black
        gfx.fillRect(0, 0, 400, 240)
        
        -- draw a series of overlapping wedges for the torch
        gfx.setPattern({0x0, 0x44, 0x0, 0x11, 0x0, 0x44, 0x0, 0x11})
        gfx.fillEllipseInRect(player.x - 120, player.y - 120, 240, 240, player.direction - player.torch_width/2, player.direction + player.torch_width/2) 
        gfx.setPattern({0x0, 0x55, 0x0, 0x55, 0x0, 0x55, 0x0, 0x55})
        gfx.fillEllipseInRect(player.x - 100, player.y - 100, 200, 200, player.direction - player.torch_width/2, player.direction + player.torch_width/2) 
        gfx.setPattern({0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF})
        gfx.fillEllipseInRect(player.x - 60, player.y - 60, 120, 120, player.direction - player.torch_width/2, player.direction + player.torch_width/2) 
        gfx.setColor(gfx.kColorWhite)
        gfx.fillEllipseInRect(player.x - 30, player.y - 30, 60, 60, player.direction - player.torch_width/2, player.direction + player.torch_width/2) 
        gfx.setColor(gfx.kColorBlack)
    else
        gfx.clear()
        gfx.fillEllipseInRect(player.x - 20, player.y - 20, 40, 40, player.direction - player.torch_width/2, player.direction + player.torch_width/2) 
    end
    
    -- draw obstacle shadows
    for _, obstacle in pairs(obstacles) do
        
        if obstacle.type == 'rect' then
            for n = 1, (obstacle.geom:count()-1) do
                local vertex1_x, vertex1_y = obstacle.geom:getPointAt(n):unpack()
                local vertex1_dist = math.sqrt((vertex1_x - player.x)^2 + (vertex1_y - player.y)^2)
                local vertex2_x, vertex2_y = obstacle.geom:getPointAt(n+1):unpack()
                local vertex2_dist = math.sqrt((vertex2_x - player.x)^2 + (vertex2_y - player.y)^2)
                local vertex3_x, vertex3_y = vertex1_x + (vertex1_x - player.x) * (240 / vertex1_dist), vertex1_y + (vertex1_y - player.y) * (240 / vertex1_dist)
                local vertex4_x, vertex4_y = vertex2_x + (vertex2_x - player.x) * (240 / vertex2_dist), vertex2_y + (vertex2_y - player.y) * (240 / vertex2_dist)
                
                local shadow_poly = geom.polygon.new(vertex1_x, vertex1_y, vertex2_x, vertex2_y, vertex4_x, vertex4_y, vertex3_x, vertex3_y)
                shadow_poly:close()
                if shadows == true then
                    gfx.fillPolygon(shadow_poly)
                else
                    gfx.drawPolygon(shadow_poly)
                end
                
                
            end
        elseif obstacle.type == 'circle' then
            local obstacle_dir = math.deg(math.atan2(obstacle.y - player.y, obstacle.x - player.x))
            local vertex1_x = obstacle.x + obstacle.diameter * math.cos(math.rad(obstacle_dir-90))
            local vertex1_y = obstacle.y + obstacle.diameter * math.sin(math.rad(obstacle_dir-90))
            local vertex1_dist = math.sqrt((vertex1_x - player.x)^2 + (vertex1_y - player.y)^2)
            local vertex2_x = obstacle.x + obstacle.diameter * math.cos(math.rad(obstacle_dir+90))
            local vertex2_y = obstacle.y + obstacle.diameter * math.sin(math.rad(obstacle_dir+90))
            local vertex2_dist = math.sqrt((vertex1_x - player.x)^2 + (vertex1_y - player.y)^2)
            local vertex3_x, vertex3_y = vertex1_x + (vertex1_x - player.x) * (240 / vertex1_dist), vertex1_y + (vertex1_y - player.y) * (240 / vertex1_dist)
            local vertex4_x, vertex4_y = vertex2_x + (vertex2_x - player.x) * (240 / vertex2_dist), vertex2_y + (vertex2_y - player.y) * (240 / vertex2_dist)
            local shadow_poly = geom.polygon.new(vertex1_x, vertex1_y, vertex2_x, vertex2_y, vertex4_x, vertex4_y, vertex3_x, vertex3_y)
            shadow_poly:close()
            if shadows == true then
                gfx.fillPolygon(shadow_poly)
            else
                gfx.drawPolygon(shadow_poly)
            end
            
        end
    end
    
    for _, obstacle in pairs(obstacles) do
    
        if obstacle.type == 'rect' then
            -- draw obstacle
            if shadows == true then
                gfx.setPattern({0x0, 0x44, 0x0, 0x11, 0x0, 0x44, 0x0, 0x11})
                gfx.fillPolygon(obstacle.geom)
                local top = obstacle.geom:copy()
                top:translate(0, -obstacle.height)
                gfx.setPattern({0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF})
                gfx.fillPolygon(top)
                gfx.setColor(gfx.kColorBlack)
                gfx.drawPolygon(top)
                
            else
                gfx.drawPolygon(obstacle.geom)
            end
        
        elseif obstacle.type == 'circle' then
            -- draw obstacle
            if shadows == true then
                gfx.setPattern({0x0, 0x44, 0x0, 0x11, 0x0, 0x44, 0x0, 0x11})
                gfx.fillRect(obstacle.x - obstacle.diameter, obstacle.y - obstacle.height, obstacle.diameter * 2, obstacle.height)
                gfx.fillCircleAtPoint(obstacle.x, obstacle.y, obstacle.diameter)
                gfx.setPattern({0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF, 0x55, 0xFF})
                gfx.fillCircleAtPoint(obstacle.x, obstacle.y-obstacle.height, obstacle.diameter)
                gfx.setColor(gfx.kColorBlack)
                gfx.drawCircleAtPoint(obstacle.x, obstacle.y-obstacle.height, obstacle.diameter)
            else
                gfx.drawCircleAtPoint(obstacle.x, obstacle.y, obstacle.diameter)
            end
        end
        
        -- draw big mask
        gfx.fillEllipseInRect(player.x - 400, player.y - 400, 800, 800, player.direction + player.torch_width/2, player.direction - player.torch_width/2)
        
    end
    
    -- draw player
    gfx.drawCircleAtPoint(player.x, player.y, 5)
    
    playdate.drawFPS(0,0)
end

function update_player()
    
    -- update torch width if cranked
    player.torch_width += playdate.getCrankChange()
    if player.torch_width > 360 then player.torch_width = 360 end
    if player.torch_width <10 then player.torch_width = 10 end
    
    -- update player direction
    player.direction += input_vector.dx*3
    
    -- update player position
    player.x = player.x + input_vector.dy * math.sin(math.rad(player.direction))
    player.y = player.y - input_vector.dy * math.cos(math.rad(player.direction))
    
    -- update player light mask (a 60 degree wedge from player.x, player.y in the direction of heading)
    -- will need to actually do this in order to determine if items/enemies are in light or dark areas

end

function playdate.leftButtonDown() input_vector.dx = -1 end
function playdate.leftButtonUp() input_vector.dx = 0 end
function playdate.rightButtonDown() input_vector.dx = 1 end
function playdate.rightButtonUp() input_vector.dx = 0 end
function playdate.upButtonDown() input_vector.dy = 1 end
function playdate.upButtonUp() input_vector.dy = 0 end
function playdate.downButtonDown() input_vector.dy = -1 end
function playdate.downButtonUp() input_vector.dy = 0 end
function playdate.AButtonDown() aDown = true end
function playdate.AButtonHeld() aHeld = true end
function playdate.AButtonUp() aDown = false end
function playdate.BButtonDown() bDown = true shadows = false end
function playdate.BButtonHeld() bHeld = true end
function playdate.BButtonUp() bDown = false shadows = true end
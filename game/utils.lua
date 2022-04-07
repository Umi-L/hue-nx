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
    if s <= 0 then return {R=v,G=v,B=v} end
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
    return {R=r+m, G=g+m, B=b+m}
end

function RGBtoHSL(color)

    r = color.R
    g = color.G
    b = color.B

    r, g, b    = r/255, g/255, b/255
	local M, m =  math.max(r, g, b),
				  math.min(r, g, b)
	local c, H = M - m, 0
	if     M == r then H = (g-b)/c%6
	elseif M == g then H = (b-r)/c+2
	elseif M == b then H = (r-g)/c+4
	end	local L = 0.5*M+0.5*m
	local S = c == 0 and 0 or c/(1-math.abs(2*L-1))

    H = ((1/6)*H)*360%360
    S = S*255
    V = L*255

	return {H=H,S=S,L=L}
end

function percentBetween(a,b,percent)
    return a + (b - a) * percent
end

function interpolateColor(a,b,percent)
    r = percentBetween(a.R,b.R, percent)
    g = percentBetween(a.G,b.G, percent)
    b = percentBetween(a.B,b.B, percent)

    return {R=r,G=g,B=b}
end

function newColor(r,g,b)
    return {R=r,G=g,B=b}
end
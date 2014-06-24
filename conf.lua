-- globals having to do with the tile library
global = {}
global.tile_size = 16
global.scale = 1

function DEC_HEX(IN)
    local B,K,OUT,I,D=16,"0123456789abcdef","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
    return OUT
end

sides = { 57903887872, 1072179291, 2246282408, 102417611 }
floor_height = 28675

global.side_length   = ""
global.floor_height  = "" .. floor_height

for i, v in ipairs(sides) do
    global.side_length = global.side_length .. DEC_HEX(v)
end

function love.conf(t)
    t.window.title = "Darkest Path"
end

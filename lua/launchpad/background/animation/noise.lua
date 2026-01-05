local Noise = {}
Noise.__index = Noise

function Noise.new()
    return setmetatable({}, Noise)
end

function Noise:init(_) end

function Noise:step(engine)
    for r = 1, engine.rows do
        for c = 1, engine.cols do
            engine.grid[r][c] = math.random(#engine.palette)
        end
    end
end

return Noise

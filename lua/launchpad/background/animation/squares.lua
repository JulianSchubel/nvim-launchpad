local Registry = require("launchpad.background.animation.registry");
local Squares = {}
Squares.__index = Squares

function Squares.new()
    return setmetatable({}, Squares)
end

function Squares:init(_) end

function Squares:step(engine)
    local p = engine.opts.change_probability

    for r = 1, engine.rows do
        for c = 1, engine.cols do
            if math.random() < p then
                engine.grid[r][c] = math.random(#engine.palette)
            end
        end
    end
end

function Squares:destroy(_) end

Registry.register("squares", Squares.new)

return Squares

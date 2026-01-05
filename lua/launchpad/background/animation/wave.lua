local Wave = {}
Wave.__index = Wave

function Wave.new()
    return setmetatable({ t = 0 }, Wave)
end

function Wave:init(_) end

function Wave:step(engine)
    self.t = self.t + 0.1

    for r = 1, engine.rows do
        for c = 1, engine.cols do
            local v = math.sin(self.t + r * 0.3 + c * 0.3)
            engine.grid[r][c] =
                math.floor(((v + 1) / 2) * (#engine.palette - 1)) + 1
        end
    end
end

return Wave

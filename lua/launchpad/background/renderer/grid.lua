local Layout = require("launchpad.utilities.layout")
local Registry = require("launchpad.background.renderer.registry");

local GridRenderer = {}
GridRenderer.__index = GridRenderer

function GridRenderer.new()
    return setmetatable({}, GridRenderer)
end

function GridRenderer.init(_) end

-- Stateless render: everything comes from engine
function GridRenderer:render(engine)
    local buf  = engine.buf
    local ns   = engine.ns
    local grid = engine.grid
    local size = engine.opts.square_size

    -- Hard guard: fail fast
    if type(ns) ~= "number" then
        vim.notify(
            "[launchpad] GridRenderer received invalid namespace: " .. vim.inspect(ns),
            vim.log.levels.ERROR
        )
        return
    end

    vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

    for row = 1, engine.rows do
        for col = 1, engine.cols do
            local col_start, col_end =
                Layout.square_columns(col, size)

            vim.api.nvim_buf_set_extmark(
                buf,
                ns,
                row - 1, -- 0-based row
                col_start,
                {
                    end_col = col_end,
                    hl_group = "LaunchpadBg" .. grid[row][col],
                    priority = 0,
                }
            )
        end
    end
end

function GridRenderer:clear(engine)
    if type(engine.ns) == "number" then
        vim.api.nvim_buf_clear_namespace(engine.buf, engine.ns, 0, -1)
    end
end

function GridRenderer:destroy(_) end

Registry.register("grid", GridRenderer.new)

return GridRenderer

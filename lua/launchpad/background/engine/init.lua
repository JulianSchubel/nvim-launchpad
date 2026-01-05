local Colour = require("launchpad.utilities.colour")
local Layout = require("launchpad.utilities.layout")

local uv = vim.uv
local BackgroundEngine = {}
BackgroundEngine.__index = BackgroundEngine

local defaults = {
    fps = 20,
    change_probability = 0.02,
    square_size = 2,
    zindex = 1,
    fade_steps = 10,
    fade_interval = 30,
    palette = nil,
}

local AnimationRegistry =
  require("launchpad.background.animation.registry")

-- ensure default animation is loaded
require("launchpad.background.animation.fade")

local RendererRegistry = 
    require("launchpad.background.renderer.registry")
-- ensure default renderer is loaded
require("launchpad.background.renderer.grid")

function BackgroundEngine.new(opts)
    opts = vim.tbl_deep_extend("force", defaults, opts or {});

    local animation;
    local renderer;

    if type(opts.animation) == "string" then
        animation = AnimationRegistry.create(opts.animation)
    elseif type(opts.animation) == "table" then
        animation = opts.animation
    end

    if type(opts.renderer) == "string" then
        renderer = RendererRegistry.create(opts.renderer)
    elseif type(opts.renderer) == "table" then
        renderer = opts.renderer
    end

    -- guaranteed fallback
    if not animation then
        animation = AnimationRegistry.create("fade")
    end;

    local rows, cols = Layout.grid_dimensions(vim.o.lines, vim.o.columns, opts.square_size)

    local self = setmetatable({
        opts = opts,
        buf = nil,
        win = nil,
        ns = vim.api.nvim_create_namespace("launchpad-bg"),

        grid = {},
        rows = rows,
        cols = cols,

        timer = nil,
        running = false,
        visible = false,
        opacity = 0,

        renderer = renderer,
        animation = animation
    }, BackgroundEngine);
    self.palette = self:_derive_palette()
    self:_define_highlights(self.palette)

    assert(type(self.ns) == "number", "launchpad: namespace creation failed")
    assert(self.renderer, "launchpad: renderer creation failed")
    assert(self.animation, "launchpad: animation creation failed")

    BackgroundEngine.instance = self

    --pass reference to engine to animation strategies
    animation:init(self)
    --pass reeference to engine to renderers
    renderer:init(self)
    return self
end

-- THEME ----------------------------------------------------------------------

function BackgroundEngine:_derive_palette()
    if self.opts.palette then
        return self.opts.palette
    end

    local hl = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
    local bg = hl.bg or 0xffffff

    return Colour.palette_from_bg(bg, {
        0.85, 0.9, 0.95, 1.0, 1.05,
    })
end

function BackgroundEngine:_define_highlights(palette)
    palette = palette or self.palette
    if not palette then return end

    for i, colour in ipairs(palette) do
        vim.api.nvim_set_hl(0, "LaunchpadBg" .. i, { bg = colour })
    end
end

-- GRID -----------------------------------------------------------------------

function BackgroundEngine:_init_grid()
    local size = self.opts.square_size

    self.rows = vim.o.lines
    self.cols = math.floor(vim.o.columns / size)

    self.grid = {}
    for r = 1, self.rows do
        self.grid[r] = {}
        for c = 1, self.cols do
            self.grid[r][c] = math.random(#self.palette)
        end
    end
end

-- WINDOW ---------------------------------------------------------------------

function BackgroundEngine:_create_window()
    self.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[self.buf].buftype = "nofile"
    vim.bo[self.buf].bufhidden = "wipe"
    vim.bo[self.buf].modifiable = false

    self.win = vim.api.nvim_open_win(self.buf, false, {
        relative = "editor",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines,
        style = "minimal",
        focusable = false,
        zindex = self.opts.zindex,
    })

    local line = string.rep(" ", vim.o.columns)
    local lines = {}
    for _ = 1, vim.o.lines do
        lines[#lines + 1] = line
    end

    vim.bo[self.buf].modifiable = true
    vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
    vim.bo[self.buf].modifiable = false
end

-- RENDER ---------------------------------------------------------------------

function BackgroundEngine:_render()
    self.renderer:render(self)
end

-- ANIMATION ------------------------------------------------------------------

function BackgroundEngine:_step()
    self.animation:step(self)
end

function BackgroundEngine:_tick()
    if not self.running then return end
    self:_step()
    self:_render()
end

-- FADE -----------------------------------------------------------------------

function BackgroundEngine:_fade(to)
    local steps = self.opts.fade_steps
    local delta = (to - self.opacity) / steps

    for i = 1, steps do
        vim.defer_fn(function()
            if not (self.win and vim.api.nvim_win_is_valid(self.win)) then return end
            self.opacity = self.opacity + delta
            vim.wo[self.win].winblend =
                math.floor(math.max(0, math.min(1, self.opacity)) * 100)
        end, i * self.opts.fade_interval)
    end
end

-- PUBLIC API -----------------------------------------------------------------

function BackgroundEngine:show()
    if self.visible then return end

    self:_init_grid()
    self:_create_window()
    self:_render()

    self.visible = true
    self.running = true

    self.timer = uv.new_timer()
    self.timer:start(
        0,
        math.floor(1000 / self.opts.fps),
        vim.schedule_wrap(function() self:_tick() end)
    )

    self:_fade(1)
end

function BackgroundEngine:hide()
    if not self.visible then return end
    self.visible = false
    self.running = false
    self:_fade(0)

    vim.defer_fn(function()
        if self.timer then
            self.timer:stop()
            self.timer:close()
            self.timer = nil
        end
        if self.win and vim.api.nvim_win_is_valid(self.win) then
            vim.api.nvim_win_close(self.win, true)
        end
    end, self.opts.fade_steps * self.opts.fade_interval)
end

function BackgroundEngine:resize()
    if not self.visible then return end
    self:hide()
    vim.defer_fn(function() self:show() end, 50)
end

-- AUTOCMDS -------------------------------------------------------------------

vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
        if BackgroundEngine.instance then
            BackgroundEngine.instance:resize()
        end
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        local inst = BackgroundEngine.instance
        if not inst then return end
        local old = inst.palette
        local new = inst:_derive_palette()
        inst.palette = new
        inst:_define_highlights(new)
    end,
})

return BackgroundEngine

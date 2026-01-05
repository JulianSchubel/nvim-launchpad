local modal = require("launchpad.ui.modal");
local BackgroundEngine = require("launchpad.background.engine");
local config = require("launchpad.config");

local PluginAPI = require("launchpad.plugin")

local Launchpad = {}

-- public plugin API
Launchpad.register_animation = PluginAPI.register_animation
Launchpad.register_renderer  = PluginAPI.register_renderer
Launchpad.has_animation      = PluginAPI.has_animation
Launchpad.has_renderer       = PluginAPI.has_renderer

function Launchpad.setup(opts)
    opts = opts or {};
    local bg = BackgroundEngine.new(opts.background or {})
    BackgroundEngine.instance = bg
    Launchpad.background = bg
    vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
            if #vim.fn.argv() == 0 then
                config.setup(opts or {})
                require("launchpad.ui.window.open_main_window")()
            end
        end,
    });
end

-- Core public API
function Launchpad.open()
    Launchpad.background:show()
    -- open launchpad UI here
end

function Launchpad.close()
    Launchpad.background:hide()
end

return Launchpad

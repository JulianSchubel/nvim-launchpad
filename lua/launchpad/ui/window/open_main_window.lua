local config = require("launchpad.config")

local function open_main_window()
    -- Open a new empty "base" buffer for the plugin.
    vim.api.nvim_command("enew");
    -- Name the current buffer.
    vim.api.nvim_buf_set_name(0, "Launchpad");
    -- Insert background UI elements
    vim.api.nvim_buf_set_lines(0, 0, -1, false, {"Welcome to Neovim!"});
end

return open_main_window

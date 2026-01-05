local Module = {};

local defaults = {
};

function Module.setup(opts)
    Module.opts = vim.tbl_deep_extend("force", defaults, opts or {});
end

return Module;

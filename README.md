# Nvim-Launchpad  

Nvim-Launchpad is a Neovim plugin that provides a simple, organized interface to
create, manage and navigate between project directories.

This plugin is a work in progress.

![](assets/nvim-launchpad.png)

## Features
- Create and manage projects in a simple, organized interface.
- Easily navigate between different project directories.
- Customizable to make it your own.
- Exposes renderer and animation internals for consumption by plugin authors.

## Installation (Lazy.nvim)

```lua
return {
    dir = "/home/js/projects/nvim-launchpad",
--    "JulianSchubel/nvim-launchpad",
    lazy = false,
    priority = 1000,
    config = function()
        local GridRenderer =
            require("launchpad.background.renderer.grid").new()

        local Wave =
            require("launchpad.background.animation.wave").new()

        local Square =
            require("launchpad.background.animation.squares").new()

        local Noise =
            require("launchpad.background.animation.noise").new()

        local launchpad = require("launchpad").setup({
            background = {
                square_size = 15,
                fps = 2,
                renderer = GridRenderer,
                animation = nil,
                zindex = 1,
            },
        })

        launchpad.register_theme(
            "slow-dark", 
            function(engine)
                engine.opts.fps = 8;
                engine.opts.square_size = 5;
            end
        );

        launchpad.open({
            background = {
                theme = "slow-dark",
            }
        });
    end,
}```

## Usage
<details> <summary>Keymaps</summary>
</details>


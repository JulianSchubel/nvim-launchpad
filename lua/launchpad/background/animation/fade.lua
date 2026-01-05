local Registry = require("launchpad.background.animation.registry")

local Fade = {}
Fade.__index = Fade

function Fade.new()
  return setmetatable({}, Fade)
end

function Fade:init(_) end
function Fade:step(_) end
function Fade:set_mode(_) end
function Fade:destroy(_) end

Registry.register("fade", Fade.new)

return Fade


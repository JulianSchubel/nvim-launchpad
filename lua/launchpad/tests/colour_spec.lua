local Colour = require("launchpad.utilities.colour")

assert(Colour.hex_to_int("#ffffff") == 0xffffff)
assert(Colour.rgb_to_hex(255, 0, 0) == "#ff0000")

local mid = Colour.mix(0x000000, 0xffffff, 0.5)
assert(mid == "#7f7f7f" or mid == "#808080")

local darker = Colour.blend(0xffffff, 0.5)
assert(darker == "#7f7f7f")

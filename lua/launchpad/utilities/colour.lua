local bit = bit;
local Module = {};

--[[
    BASIC CONVERSIONS
]]
-- Convert a 24-bit integer colour (0xRRGGBB) to RGB components
function Module.int_to_rgb(colour)
    return
        bit.band(bit.rshift(colour, 16), 0xff),
        bit.band(bit.rshift(colour, 8), 0xff),
        bit.band(colour, 0xff)
end

-- Convert RGB components back to hex string
function Module.rgb_to_hex(r, g, b)
    return string.format("#%02x%02x%02x", r, g, b)
end

--Convert hex to RGB
function Module.hex_to_int(hex)
    hex = hex:gsub("#", "");
    return tonumber(hex, 16);
end;

--[[
    GAMMA CORRECTION
]]
--Gamma correction is a non-linear operation that adjusts
--the brightness levels (luminance) in digital images and
--videos to match the non-linear way human eyes perceive light,
--making dark areas more detailed and ensuring consistent
--appearance across different screens. It uses a power-law function
--(input^gamma) to either brighten or darken mid-tones, crucial for
--encoding light data efficiently and accurately displaying colours,
--preventing washed-out or overly dark images.
--
--The Problem:
--  Cameras capture light linearly, but screens and human eyes process
--  it non-linearly (we're more sensitive to changes in dark areas).
--The Solution: A gamma curve (often around 2.2) adjusts the brightness levels:
--      Gamma < 1 (e.g., 0.5): Brightens mid-tones, making shadows lighter
--      (gamma compression for display).
--      Gamma > 1 (e.g., 2.2): Darkens mid-tones, making shadows darker
--      (gamma encoding for storage/transmission).
--The Formula: Output = Input^gamma

local function to_linear(c)
    c = c / 255
    if c <= 0.04045 then
        return c / 12.92
    end
    return ((c + 0.055) / 1.055) ^ 2.4
end

local function to_srgb(c)
    if c <= 0.0031308 then
        return c * 12.92
    end
    return 1.055 * (c ^ (1 / 2.4)) - 0.055
end

--[[
    COLOUR OPERATIONS
]]
function Module.mix(colour_a, colour_b, t)
    local ar, ag, ab = Module.int_to_rgb(colour_a)
    local br, bg, bb = Module.int_to_rgb(colour_b)

    ar, ag, ab = to_linear(ar), to_linear(ag), to_linear(ab)
    br, bg, bb = to_linear(br), to_linear(bg), to_linear(bb)

    local r = to_srgb(ar + (br - ar) * t)
    local g = to_srgb(ag + (bg - ag) * t)
    local b = to_srgb(ab + (bb - ab) * t)

    return Module.rgb_to_hex(
        math.floor(r * 255),
        math.floor(g * 255),
        math.floor(b * 255)
    )
end

-- Blend a colour by a factor (< 1 darken, > 1 lighten)
function Module.blend(colour, factor)
    local r, g, b = Module.int_to_rgb(colour)

    r = math.min(255, math.floor(r * factor))
    g = math.min(255, math.floor(g * factor))
    b = math.min(255, math.floor(b * factor))

    return Module.rgb_to_hex(r, g, b)
end

-- Generate a stepped palette from a base colour
function Module.palette_from_bg(bg, factors)
    local palette = {}
    for _, f in ipairs(factors) do
        table.insert(palette, Module.blend(bg, f))
    end
    return palette
end

return Module;

local Layout = require("launchpad.utilities.layout")

local r, c = Layout.grid_dimensions(40, 120, 3)
assert(r == 40)
assert(c == 40)

local s, e = Layout.square_columns(2, 4)
assert(s == 4 and e == 8)

local win = Layout.centered_window(100, 50, 40, 20)
assert(win.row == 15)
assert(win.col == 30)

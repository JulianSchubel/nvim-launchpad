local Module = {}

function Module.grid_dimensions(screen_lines, screen_cols, square_size)
    return
        math.floor(screen_lines),
        math.floor(screen_cols / square_size)
end

function Module.square_columns(col, size)
    local start = (col - 1) * size
    return start, start + size
end

function Module.centered_window(screen_w, screen_h, w, h)
    return {
        row = math.floor((screen_h - h) / 2),
        col = math.floor((screen_w - w) / 2),
        width = w,
        height = h,
    }
end

return Module

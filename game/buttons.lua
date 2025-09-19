local buttons = {}

local Button = {}

local function pointInRect(px, py, x, y, w, h)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

function Button:createButton(self, opts)
    -- opts: x,y,w,h,label, onPress(btn), onRelease(btn)
    local btn = {
        x = opts.x,
        y = opts.y,
        w = opts.w,
        h = opts.h,
        label = opts.label or "",
        pressed = false,
        id = nil, -- touch id or "mouse"
        onPress = opts.onPress,
        onRelease = opts.onRelease or function () end,
        rectangle = opts.rectangle or false
    }
    table.insert(buttons, btn)
    return btn
end

function Button:draw(self)
    -- Рисуем кнопки
    for _, b in ipairs(buttons) do
        if b.pressed then
            love.graphics.setColor(0,0,0,0.55)
        else
            love.graphics.setColor(0,0,0,0.45)
        end
        
        local value = b.pressed and 6 or 0
        
        if b.rectangle then
            love.graphics.rectangle("fill", b.x - value, b.y  - value, b.w + value * 2, b.h + value * 2)
            love.graphics.setColor(0,0,0,0.6)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", b.x - value, b.y  - value, b.w + value * 2, b.h + value * 2)
        else
            local bx, by = b.x + b.w *0.5, b.y + b.w *0.5
            love.graphics.circle("fill", bx, by, b.w * 0.5 + value)
            love.graphics.setColor(1,1,1,0.06)
            love.graphics.circle("fill", bx, by, b.w * 0.4 + value)
            -- outline base
            love.graphics.setColor(0,0,0,0.6)
            love.graphics.setLineWidth(2)
            love.graphics.circle("line", bx, by, b.w * 0.5 + value)
        end
        
        local font = love.graphics.getFont()
        local txt = b.label
        local tw = font:getWidth(txt)
        local th = font:getHeight()
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(txt, b.x + (b.w - tw) / 2, b.y + (b.h - th) / 2)
    end
end

function Button:touchpressed(id, x, y, pressure)
    for _, b in ipairs(buttons) do
        if not b.pressed and pointInRect(x, y, b.x, b.y, b.w, b.h) then
            b.pressed = true
            b.id = id
            if b.onPress then b.onPress(b) end
            return true
        end
    end
    return false
end

function Button:touchmoved(id, tx, ty, dx, dy, pressure)
    for _, b in ipairs(buttons) do
        if b.id == id then
            -- если палец ушёл за пределы — не будем отпускать автоматически, но можно реализовать cancel
            -- b.pressed = pointInRect(tx, ty, b.x, b.y, b.w, b.h)
            return true
        end
    end
    return false
end

function Button:touchreleased(id, tx, ty, pressure)
    for _, b in ipairs(buttons) do
        if b.id == id then
            local wasPressed = b.pressed
            b.pressed = false
            b.id = nil
            if wasPressed and b.onRelease then b.onRelease(b) end
            return true
        end
    end
    return false
end

return Button
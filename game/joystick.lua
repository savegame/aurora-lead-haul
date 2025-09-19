local joystick = {
    active = false,
    id = nil,         -- touch id / mouse id
    baseX = 0,
    baseY = 0,        -- позиция основания
    stickX = 0,
    stickY = 0,       -- позиция стикa (мир/экран)
    radius = 60,      -- радиус основания
    deadzone = 8,     -- мёртвая зона
    maxDistance = 48, -- максимальная длина стика от центра

    startJoystick = function(self, id, x, y)
        if self.id ~= nil then
            return
        end
    
        self.active = true
        self.id = id
        self.baseX = x
        self.baseY = y
        self.stickX = x
        self.stickY = y
    end,

    moveJoystick = function(self, x, y)
        local dx = x - self.baseX
        local dy = y - self.baseY
        local dist = math.sqrt(dx * dx + dy * dy)
        if dist <= self.deadzone then
            self.stickX = self.baseX
            self.stickY = self.baseY
        else
            local maxd = self.maxDistance
            if dist > maxd then
                dx = dx / dist * maxd
                dy = dy / dist * maxd
            end
            self.stickX = self.baseX + dx
            self.stickY = self.baseY + dy
        end
    end,

    stopJoystick = function(self)
        self.active = false
        self.id = nil
        self.stickX = self.baseX
        self.stickY = self.baseY
    end,

    draw = function (self)
        if not self.active then
            return
        end
        -- base
        love.graphics.setColor(0,0,0,0.45)
        love.graphics.circle("fill", self.baseX, self.baseY, self.radius)
        love.graphics.setColor(1,1,1,0.06)
        love.graphics.circle("fill", self.baseX, self.baseY, self.maxDistance)
        -- outline base
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", self.baseX, self.baseY, self.radius)
        -- stick
        love.graphics.setColor(1,1,1,0.9)
        love.graphics.circle("fill", self.stickX, self.stickY, self.radius*0.45)
        -- outline stick
        love.graphics.setColor(0,0,0,0.6)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", self.stickX, self.stickY, self.radius*0.45)
    end
}

return joystick
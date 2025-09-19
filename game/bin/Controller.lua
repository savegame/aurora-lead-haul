local file = { priority = 0 }

Controller = {}

function Controller:new()
    local inst = Class:init(Controller)

    inst.binds = {
        moveForward = "w",
        moveBack = "s",
        moveLeft = "a",
        moveRight = "d",
        jump = "space",
        interact = "e",
        toggleFullscreen = "f1",
        fire = "m1",
        melee = "q",
        equipPistol = "1",
        equipShotgun = "2",
        equipMachinegun = "3",
        equipChargerifle = "4",
        equipRocketLauncher = "5",
        menuSelect = "m1",
        pause = "escape",
        nextWeapon = "wheelDown",
        previousWeapon = "wheelUp",
    }

    inst.mouse = {
        moved = false,
        sensitivity = 1,
        dx = 0,
        dy = 0,
        x = 0,
        y = 0
    }

    local joysticks = love.joystick.getJoysticks()
    inst.joystick = nil
    if #joysticks > 0 then
        inst.joystick = joysticks[1]
        print("Found joystick: " .. inst.joystick:getName())
    end

    inst.screenjoystick = require "joystick"
    inst.button = require "buttons"

    local screenW, screenH = love.graphics.getDimensions()
    local bw = 80
    local bh = 80
    -- local margin = 10

    inst.screenButtons = {
        button_fire = inst.button:createButton(inst.button, {
            x = screenW - bw - 100,
            y = screenH - bh - 140,
            w = bw, h = bh,
            label = "FIRE",
            onPress = function(b) 
                inst.joystickButtonState.righttrigger = true
            end,
            onRelease = function(b) 
                inst.joystickButtonState.righttrigger = false
            end,
        }),
        button_interact = inst.button:createButton(inst.button, {
            x = screenW - 60 - 16,
            y = screenH - 60 - 200,
            w = 60, h = 60,
            label = "E",
            onPress = function(b) 
                inst.joystickButtonState.buttonY = true
            end,
            onRelease = function(b) 
                inst.joystickButtonState.buttonY = false
            end,
        }),
        button_knife = inst.button:createButton(inst.button, {
            x = screenW - 60 - 16,
            y = screenH - 60 - 124,
            w = 60, h = 60,
            label = "Q",
            onPress = function(b) 
                inst.joystickButtonState.buttonX = true
            end,
            onRelease = function(b) 
                inst.joystickButtonState.buttonX = false
            end,
        }),
        button_pw = inst.button:createButton(inst.button, {
            x = screenW * 0.5 - 80 - 8,
            y = screenH - 66,
            w = 80, h = 40,
            label = "PREV",
            onPress = function(b)
                table.insert(presses, {key = "wheelUp", id = "wheel"})
            end,
            onRelease = function(b)
            end,
            rectangle = true
        }),
        button_nw = inst.button:createButton(inst.button, {
            x = screenW * 0.5 + 8,
            y = screenH - 66,
            w = 80, h = 40,
            label = "NEXT",
            onPress = function(b)
                table.insert(presses, {key = "wheelDown", id = "wheel"})
            end,
            onRelease = function(b)
            end,
            rectangle = true
        }),
        button_pause = inst.button:createButton(inst.button, {
            x = 16,
            y = 16,
            w = 80, h = 40,
            label = "MENU",
            onPress = function(b)
                table.insert(presses, {key = "escape", id = "keyboard"})
            end,
            onRelease = function(b)
                table.insert(releases, {key = "escape"})
            end,
            rectangle = true
        }),
    }

    inst.joystickButtonState = {
        righttrigger = false,
        buttonA = false,
        buttonY = false,
        buttonX = false,
    }

    return inst
end

function Controller.setAimSensitivity(self, sensitivity)
    self.mouse.sensitivity = sensitivity
end

function Controller.resetMouseDelta(self)
    if not self.mouse.moved then
        self.mouse.dx = 0
        self.mouse.dy = 0
    else
        self.mouse.moved = false
    end
end

function Controller.toggleFullscreen(self)
    if Input:isPressed(self.binds.toggleFullscreen) then
        lw.setFullscreen(not lw.getFullscreen())
    end
end

function Controller.setMousePos(self)
    -- self.mouse.x = lm.getX()
    -- self.mouse.y = lm.getY()
    -- self.mouse.x, self.mouse.y = love.mouse.getPosition()
    -- print(("Mouse pos for menu is: %2ix%2i"):format(self.mouse.x, self.mouse.y))

    if self.joystick == nil then
        return
    end
    
    self.mouse.dx = self.joystick:getGamepadAxis("rightx") * 1.5
    self.mouse.dy = self.joystick:getGamepadAxis("righty") * 1.5

    self.joystickButtonState.righttrigger = self.joystick:getGamepadAxis("triggerright") > 0.3 and true or false
    self.joystickButtonState.buttonA = self.joystick:isGamepadDown("a")
    self.joystickButtonState.buttonY = self.joystick:isGamepadDown("y")
    self.joystickButtonState.buttonX = self.joystick:isGamepadDown("x")
end

function Controller.updateGamepad(self)
    
end

function Controller.update(self)
    self:resetMouseDelta()
    self:toggleFullscreen()
    self:setMousePos()
    self.updateGamepad()
end

function Controller.getMoveDir(self)
    local dx, dz = 0, 0
    local returnDir = false

    if lk.isDown(self.binds.moveForward) then dz = dz - 1 end
    if lk.isDown(self.binds.moveBack) then dz = dz + 1 end
    if lk.isDown(self.binds.moveLeft) then dx = dx - 1 end
    if lk.isDown(self.binds.moveRight) then dx = dx + 1 end

    if self.joystick then
        dx = self.joystick:getGamepadAxis("leftx")
        dz = self.joystick:getGamepadAxis("lefty")
    end
    if self.screenjoystick then
        -- print(("Screen joystick: %.2f x %.2f"):format(self.screenjoystick.stickX, self.screenjoystick.stickY))
        dx = self.screenjoystick.dx
        dz = self.screenjoystick.dy
    end

    if dx ~= 0 or dz ~= 0 then
        returnDir = math.atan2(dz, dx)
    end

    return returnDir
end

function Controller.isJumping(self)
    return lk.isDown(self.binds.jump) or self.joystickButtonState.buttonA
end

function Controller.getCameraDirDelta(self)
    return self.mouse.dx * self.mouse.sensitivity * hdt, self.mouse.dy * self.mouse.sensitivity * hdt
end

function Controller.isInteracting(self)
    return Input:isPressed(self.binds.interact) or self.joystickButtonState.buttonY
end

function Controller.isFiring(self)
    if self.screenjoystick and Game.state == "playing" then
        return self.joystickButtonState.righttrigger or self.screenButtons.button_fire.pressed
    end
    return Input:isDown(self.binds.fire) or self.joystickButtonState.righttrigger
end

function Controller.isMeleeing(self)
    return Input:isPressed(self.binds.melee) or self.joystickButtonState.buttonX
end

function Controller.isMenuSelecting(self)
    return Input:isReleased(self.binds.menuSelect)
end

function Controller.isMenuHolding(self)
    return Input:isDown(self.binds.menuSelect)
end

function Controller.getCursorPos(self)
    return self.mouse.x / Hud.scale, self.mouse.y / Hud.scale
end

function Controller.toggledPause(self)
    return Input:isPressed(self.binds.pause)
end

function Controller.getSwappedWeapon(self, index)
    local weapons = {
        weapon_pistol,
        weapon_shotgun,
        weapon_machinegun,
        weapon_chargerifle,
        weapon_rocketlauncher
    }

    if index then
        return weapons[index]
    end

    local newWeapon = false

    if Input:isPressed(self.binds.equipPistol) then
        newWeapon = weapons[1]
    end
    if Input:isPressed(self.binds.equipShotgun) then
        newWeapon = weapons[2]
    end
    if Input:isPressed(self.binds.equipMachinegun) then
        newWeapon = weapons[3]
    end
    if Input:isPressed(self.binds.equipChargerifle) then
        newWeapon = weapons[4]
    end
    if Input:isPressed(self.binds.equipRocketLauncher) then
        newWeapon = weapons[5]
    end

    for i = 1, #weapons do
        if not newWeapon and weapons[i].name == Player.weapon.name then
            index = i
        end
    end

    if index then
        if Input:isPressed(self.binds.nextWeapon) then
            newWeapon = weapons[(index + 1) % #weapons]
        end
        if Input:isPressed(self.binds.previousWeapon) then
            newWeapon = weapons[(index - 1) % #weapons]
        end
    end

    return newWeapon
end

function love.mousemoved(x, y, dx, dy)
    if Game.state == "playing" then
        return
    end
    Controller.mouse.x = x
    Controller.mouse.y = y
    Controller.mouse.dx = dx
    Controller.mouse.dy = dy
    Controller.mouse.moved = true
end

function love.joystickadded(joystick)
    if Controller.joystick == nil then
        Controller.joystick = joystick
        print("Joystick added: " .. joystick:getName())
    end
end

function love.joystickremoved(joystick)
    if Controller.joystick == joystick then
        Controller.joystick = nil
        print("Joystick removed: " .. joystick:getName())
    end
end

function love.touchpressed(id ,x ,y ,dx ,dy ,pressure)
    if Game.state == "playing" then
        if not Controller.button:touchpressed(id, x, y, pressure) 
           and Controller.screenjoystick 
           and x < love.graphics.getWidth() * 0.5
        then
            Controller.screenjoystick:startJoystick(id, x, y)
        end
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if Controller.screenjoystick and Controller.screenjoystick.id == id then 
        Controller.screenjoystick:moveJoystick(id, x, y)
    elseif x >= love.graphics.getWidth() * 0.5 and Game.state == "playing" then
        Controller.mouse.x = x
        Controller.mouse.y = y
        Controller.mouse.dx = dx
        Controller.mouse.dy = dy
        Controller.mouse.moved = true

        Controller.button:touchmoved(id, x, y, dx, dy, pressure)
    end
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if Controller.screenjoystick then 
        Controller.screenjoystick:stopJoystick(id)
    end
    Controller.button:touchreleased(id, x, y, pressure)
end

function file:init()
    Controller = Controller:new()
end

function file:update()
    Controller:update()
end

function file:draw()
    if Controller.screenjoystick then 
        Controller.screenjoystick:draw() 
    end
    if Game.state == "playing" then
        Controller.button:draw()
    end
end

-- [[ RETURN ]] --
return file

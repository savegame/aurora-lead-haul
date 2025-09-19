local file = {priority = -1}

Screen = { }

function Screen:new( )
	local inst = Class:init( Screen )
	local w, h = love.graphics.getDimensions()
	-- local aspect = w / h
	
	inst.baseWidth = w --640
	inst.baseHeight = h --360
	
	inst.width = inst.baseWidth
	inst.height = inst.baseHeight
	
	print(("Create Screen.canvas: %2ix%2i"):format( inst.width, inst.height ))
	inst.canvas = lg.newCanvas( inst.width, inst.height )
	
	return inst
end


function Screen.setResolutionScale( self, scale )
	local baseW,baseH = 640,360
	self.width = baseW * scale
	self.height = baseH * scale
	print(("Create Screen.canvas: %2ix%2i"):format( self.width, self.height ))
	self.canvas = lg.newCanvas( self.width, self.height )
end


function Screen.applySettings( self )
	lg.setCanvas( { self.canvas, depth = true } )
	lg.clear( 0,0,0,0 )
end

function Screen.update( self )
	
end


function Screen.draw( self )
	self:applySettings()
end


function file:init()
	Screen = Screen:new()
end

function file:update()
	Screen:update()
end

function file:draw()
	Screen:draw()
end

-- [[ RETURN ]] --
return file
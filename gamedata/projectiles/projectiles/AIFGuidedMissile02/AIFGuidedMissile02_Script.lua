local AGuidedMissileProjectile = import('/lua/aeonprojectiles.lua').AGuidedMissileProjectile

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

AIFGuidedMissile02 = Class(AGuidedMissileProjectile) {

    OnCreate = function(self)
		AGuidedMissileProjectile.OnCreate(self)
		self:ForkThread( self.MovementThread )
    end,
    
	MovementThread = function(self)
		WaitSeconds(0.6)
		self:TrackTarget(true)
	end,    
}
TypeClass = AIFGuidedMissile02


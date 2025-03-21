local CAAMissileNaniteProjectile = import('/lua/cybranprojectiles.lua').CAAMissileNaniteProjectile

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

CAAMissileNanite02 = Class(CAAMissileNaniteProjectile) {

    OnCreate = function(self)
        CAAMissileNaniteProjectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,

    UpdateThread = function(self)
        WaitSeconds(1.5)
		if not self:BeenDestroyed() then
			self:SetMaxSpeed(80)
			self:SetAcceleration(10 + Random() * 8)
			self:ChangeMaxZigZag(0.5)
			self:ChangeZigZagFrequency(2)
		end
    end,

    OnImpact = function(self, TargetType, TargetEntity)
        CAAMissileNaniteProjectile.OnImpact(self, TargetType, TargetEntity)
    end,
}

TypeClass = CAAMissileNanite02


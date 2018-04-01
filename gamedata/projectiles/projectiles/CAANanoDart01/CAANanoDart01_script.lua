local CAANanoDartProjectile03 = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile03

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

local CreateEmitterOnEntity = CreateEmitterOnEntity

CAANanoDart01 = Class(CAANanoDartProjectile03) {

	OnCreate = function(self)
	
        CAANanoDartProjectile03.OnCreate(self)
		
        self:ForkThread(self.UpdateThread)
		
	end,


    UpdateThread = function(self)
	
		self:SetMaxSpeed(3.2)
        self:SetBallisticAcceleration(-0.5)
		
        WaitSeconds(0.6)
		
        local army = self:GetArmy()
		local CreateEmitterOnEntity = CreateEmitterOnEntity

        for i in self.FxTrails do
            CreateEmitterOnEntity(self,army,self.FxTrails[i])
        end

        WaitSeconds(0.2)
		
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')
		
        self:SetMaxSpeed(65)
        self:SetAcceleration(13 + Random() * 5)

        WaitSeconds(0.3)
		
        self:SetTurnRate(360)

    end,
	
}

TypeClass = CAANanoDart01

--
-- Cybran Anti Air Projectile
--

local CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile
local ForkThread = ForkThread
local WaitSeconds = WaitSeconds
local CreateEmitterOnEntity = CreateEmitterOnEntity

CAANanoDart01 = Class(CAANanoDartProjectile) {

   OnCreate = function(self)
        CAANanoDartProjectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
   end,


    UpdateThread = function(self)
		local WaitSeconds = WaitSeconds
        WaitSeconds(0.35)
        self:SetMaxSpeed(2)
        self:SetBallisticAcceleration(-0.5)
		
        local army = self:GetArmy()
		local CreateEmitterOnEntity = CreateEmitterOnEntity

        for i in self.FxTrails do
            CreateEmitterOnEntity(self,army,self.FxTrails[i])
        end

        WaitSeconds(0.5)
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')
        self:SetMaxSpeed(50)
        self:SetAcceleration(8 + Random() * 5)

        WaitSeconds(0.3)
        self:SetTurnRate(360)

    end,
}

TypeClass = CAANanoDart01

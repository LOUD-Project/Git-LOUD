
CAANanoDartProjectile = import('/lua/cybranprojectiles.lua').CAANanoDartProjectile

local WaitTicks = coroutine.yield

CAANanoDart01 = Class(CAANanoDartProjectile) {

    OnCreate = function(self)
        CAANanoDartProjectile.OnCreate(self)
        self:ForkThread(self.UpdateThread)
    end,


    UpdateThread = function(self)
        WaitTicks(1)
        self:SetBallisticAcceleration(-0.5)
        local army = self:GetArmy()

        for i in self.FxTrails do
            CreateEmitterOnEntity(self,army,self.FxTrails[i])
        end

        WaitTicks(2)
        self:SetMesh('/projectiles/CAANanoDart01/CAANanoDartUnPacked01_mesh')

    end,
}

TypeClass = CAANanoDart01

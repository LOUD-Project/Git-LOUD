#
# Terran Gauss Cannon Projectile
#
local TDFGaussCannonProjectile = import('/lua/terranprojectiles.lua').TDFLandGaussCannonProjectile
MegaGauss01 = Class(TDFGaussCannonProjectile) {

    FxLandHitScale = 2,
    FxUnitHitScale = 2,
    
    OnCreate = function(self, inWater)
        TDFGaussCannonProjectile.OnCreate(self, inWater)
        if not inWater then
            self:SetDestroyOnWater(true)
        else
            self:ForkThread(self.DestroyOnWaterThread)
        end
    end,
    
    DestroyOnWaterThread = function(self)
        WaitSeconds(0.2)
        self:SetDestroyOnWater(true)
    end,
}
TypeClass = MegaGauss01


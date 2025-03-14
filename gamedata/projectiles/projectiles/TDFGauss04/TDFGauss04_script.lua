local TDFGaussCannonProjectile = import('/lua/terranprojectiles.lua').TDFLandGaussCannonProjectile

local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

TDFGauss04 = Class(TDFGaussCannonProjectile) {
    
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

TypeClass = TDFGauss04


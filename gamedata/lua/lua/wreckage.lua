--******************************************************************
--**  File     : /lua/wreckage.lua
--**  Summary  : Class for wreckage so it can get pushed around
--**  Copyright 2006 Gas Powered Games, Inc.  All rights reserved.
--******************************************************************
local Prop = import('/lua/sim/Prop.lua').Prop

Wreckage = Class(Prop) {

    OnCreate = function(self)
        Prop.OnCreate(self)
    end,
    
    OnDamage = function(self, instigator, amount, vector, damageType)
        self:DoTakeDamage(instigator, amount, vector, damageType)
    end,

    DoTakeDamage = function(self, instigator, amount, vector, damageType)
		
        self:AdjustHealth(instigator, -amount)
		
        local health = self:GetHealth()
		
        if health > 0 then
            local healthRatio = health / self:GetMaxHealth()
			
            if not self.MaxReclaimTimeMassMult then
                self.MaxReclaimTimeMassMult = self.ReclaimTimeMassMult
            end
			
            if not self.MaxReclaimTimeEnergyMult then
                self.MaxReclaimTimeEnergyMult = self.ReclaimTimeEnergyMult
            end
			
            self:SetReclaimValues( self.MaxReclaimTimeMassMult * healthRatio, self.MaxReclaimTimeEnergyMult * healthRatio, self.MaxMassReclaim * healthRatio, self.MaxEnergyReclaim * healthRatio )
			
        else
            self:Destroy()
        end
    end,
    
    OnCollisionCheck = function(self, other)
        if IsUnit(other) then
            return false
        end
		
        return true
    end,
}

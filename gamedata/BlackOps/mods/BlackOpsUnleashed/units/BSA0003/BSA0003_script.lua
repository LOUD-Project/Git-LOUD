local SAirUnit = import('/lua/defaultunits.lua').AirUnit

local AutoGun = import('/lua/seraphimweapons.lua').SDFPhasicAutoGunWeapon

local ForkThread = ForkThread
local WaitTicks = coroutine.yield

BSA0003 = Class(SAirUnit) {
    Weapons = {
        Turret = Class(AutoGun) {},
    },

    OnStopBeingBuilt = function(self, builder, layer)
    
        SAirUnit.OnStopBeingBuilt(self,builder,layer)

        if not self.Dead then
            self:SetMaintenanceConsumptionActive()
            self:ForkThread(self.ResourceThread)
            self:SetVeterancy(5)
			self.Brain = self:GetAIBrain()
        end
		
    end,
    
    OnKilled = function(self, instigator, type, overkillRatio)
	
        self:SetWeaponEnabledByLabel('TurretLeft', false)
        self:SetWeaponEnabledByLabel('TurretRight', false)

        IssueClearCommands(self)

        SAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    ResourceThread = function(self) 
    
    	if not self.Dead then
        	local energy = self.Brain:GetEconomyStored('Energy')

        	if  energy <= 10 then 
				self:ForkThread(self.KillFactory)
			else
            	self:ForkThread(self.EconomyWaitUnit)
        	end
    	end
		
	end,

	EconomyWaitUnit = function(self)
    	if not self.Dead then
            WaitTicks(50)

        	if not self.Dead then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,
	
	KillFactory = function(self)
    	self:Kill()
	end,

}
TypeClass = BSA0003
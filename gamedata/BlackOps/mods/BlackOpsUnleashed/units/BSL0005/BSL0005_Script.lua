
local SLandUnit = import('/lua/seraphimunits.lua').SLandUnit
local WeaponsFile = import('/lua/seraphimweapons.lua')
local SDFThauCannon = WeaponsFile.SDFThauCannon
local SDFAireauBolter = WeaponsFile.SDFAireauBolterWeapon
local SANUallCavitationTorpedo = WeaponsFile.SANUallCavitationTorpedo

local ForkThread = ForkThread

BSL0005 = Class(SLandUnit) {
    Weapons = {
        MainTurret = Class(SDFThauCannon) {},
        Torpedo01 = Class(SANUallCavitationTorpedo) {},
        LeftTurret = Class(SDFAireauBolter) {},
        RightTurret = Class(SDFAireauBolter) {},
    },


    OnStopBeingBuilt = function(self, builder, layer)
	
		SLandUnit.OnStopBeingBuilt(self,builder,layer)
        
        if not self.Dead then

            self:SetMaintenanceConsumptionActive()
            self:ForkThread(self.ResourceThread)
            self:SetVeterancy(5)
			self.Brain = self:GetAIBrain()
        end
    end,

    
    OnKilled = function(self, instigator, type, overkillRatio)

        self:SetWeaponEnabledByLabel('MainTurret', false)
        self:SetWeaponEnabledByLabel('Torpedo01', false)
        self:SetWeaponEnabledByLabel('LeftTurret', false)
        self:SetWeaponEnabledByLabel('RightTurret', false)

        IssueClearCommands(self)

        SLandUnit.OnKilled(self, instigator, type, overkillRatio)
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
			
        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,
	
	KillFactory = function(self)
    	self:Kill()
	end,

}

TypeClass = BSL0005
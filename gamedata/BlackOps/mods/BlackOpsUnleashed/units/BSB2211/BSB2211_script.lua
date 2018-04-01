
local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local SeraMineExplosion = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').SeraMineExplosion
local SeraMineDeathExplosion = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').SeraMineDeathExplosion

BSB2211 = Class(TStructureUnit) {
	Weapons = {

        DeathWeapon = Class(SeraMineDeathExplosion) {},
        
        Suicide = Class(SeraMineExplosion) {        
			OnFire = function(self)			
				#disable death weapon 
				self.unit:SetDeathWeaponEnabled(false)
				SeraMineExplosion.OnFire(self)
			end,
        },
    },
	
	OnCreate = function(self,builder,layer)
		TStructureUnit.OnCreate(self,builder,layer)
        self:SetMaintenanceConsumptionActive()
		self:ForkThread(self.LifeThread)
	end,
	
	LifeThread = function(self)
        WaitSeconds(300)
        self:Destroy()
    end,
    
}


TypeClass = BSB2211


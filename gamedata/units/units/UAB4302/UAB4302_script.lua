local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAMSaintWeapon = import('/lua/aeonweapons.lua').AAMSaintWeapon
local nukeFiredOnGotTarget = false

UAB4302 = Class(AStructureUnit) {

    Weapons = {

        MissileRack = Class(AAMSaintWeapon) {},
		MissileRack2 = Class(AAMSaintWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		AStructureUnit.OnStopBeingBuilt(self,builder,layer)

        if import('/lua/game.lua').NukesRestricted() then
            self:StopSiloBuild()
        end
	end,	    
}

TypeClass = UAB4302
local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SIFHuAntiNukeWeapon = import('/lua/seraphimweapons.lua').SIFHuAntiNukeWeapon
local nukeFiredOnGotTarget = false

XSB4302 = Class(SStructureUnit) {

    Weapons = {
        MissileRack = Class(SIFHuAntiNukeWeapon) {},
		MissileRack2 = Class(SIFHuAntiNukeWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		SStructureUnit.OnStopBeingBuilt(self,builder,layer)

        if import('/lua/game.lua').NukesRestricted() then
            self:StopSiloBuild()
        end
	end,    
}

TypeClass = XSB4302
local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CAMEMPMissileWeapon = import('/lua/cybranweapons.lua').CAMEMPMissileWeapon
local CAntiNukeLaunch01 = import('/lua/EffectTemplates.lua').CAntiNukeLaunch01


URB4302 = Class(CStructureUnit) {
    Weapons = {
        MissileRack = Class(CAMEMPMissileWeapon) {
            FxMuzzleFlash = CAntiNukeLaunch01,
        },

		MissileRack2 = Class(CAMEMPMissileWeapon) {
            FxMuzzleFlash = CAntiNukeLaunch01,
        },
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		CStructureUnit.OnStopBeingBuilt(self,builder,layer)

        if import('/lua/game.lua').NukesRestricted() then
            self:StopSiloBuild()
        end
	end,
}

TypeClass = URB4302
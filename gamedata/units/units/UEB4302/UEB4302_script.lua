local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TAMInterceptorWeapon = import('/lua/terranweapons.lua').TAMInterceptorWeapon
local nukeFiredOnGotTarget = false

UEB4302 = Class(TStructureUnit) {
    Weapons = {
        AntiNuke = Class(TAMInterceptorWeapon) {},
		AntiNuke2 = Class(TAMInterceptorWeapon) {},
    },
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TStructureUnit.OnStopBeingBuilt(self,builder,layer)

        if import('/lua/game.lua').NukesRestricted() then
            self:StopSiloBuild()
        end
	end,
}

TypeClass = UEB4302
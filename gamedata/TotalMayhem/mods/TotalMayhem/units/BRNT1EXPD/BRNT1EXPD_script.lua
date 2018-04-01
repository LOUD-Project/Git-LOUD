local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TAMPhalanxWeapon = import('/lua/terranweapons.lua').TAMPhalanxWeapon

local CreateRotator = CreateRotator

BRNT1EXPD = Class(TStructureUnit) {

    Weapons = {
	
        gatling1 = Class(TAMPhalanxWeapon) {
		
            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'spinner02', 'z', nil, 180, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(180)
                end
                TAMPhalanxWeapon.PlayFxWeaponUnpackSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
				end
				
                TAMPhalanxWeapon.PlayFxWeaponPackSequence(self)
			end,
        },

        gatling2 = Class(TAMPhalanxWeapon) {
		
            PlayFxWeaponUnpackSequence = function(self)
			
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'spinner01', 'z', nil, 180, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(180)
                end
				
                TAMPhalanxWeapon.PlayFxWeaponUnpackSequence(self)
            end,

            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
				
                TAMPhalanxWeapon.PlayFxWeaponPackSequence(self)
            end,
        },
    },
}

TypeClass = BRNT1EXPD
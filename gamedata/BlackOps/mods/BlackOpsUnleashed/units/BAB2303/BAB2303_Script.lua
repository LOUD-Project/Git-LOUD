local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFArtilleryMiasmaShellWeapon = import('/lua/aeonweapons.lua').AIFArtilleryMiasmaShellWeapon

BAB2303 = Class(AStructureUnit) {

    Weapons = {
	
        MainGun = Class(AIFArtilleryMiasmaShellWeapon) {
		
			PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
				if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                AIFArtilleryMiasmaShellWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Rotator1', 'y', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(320)
                end
				
				if not self.SpinManip2 then 
                    self.SpinManip2 = CreateRotator(self.unit, 'Rotator2', 'y', nil, -270, -180, -60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-320)
                end
                AIFArtilleryMiasmaShellWeapon.PlayFxWeaponUnpackSequence(self)
            end,       
		
		
		},
    },
}

TypeClass = BAB2303
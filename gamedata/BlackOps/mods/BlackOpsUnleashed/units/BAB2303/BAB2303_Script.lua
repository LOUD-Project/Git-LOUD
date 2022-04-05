local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFArtilleryMiasmaShellWeapon = import('/lua/aeonweapons.lua').AIFArtilleryMiasmaShellWeapon

local TrashAdd = TrashBag.Add

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
                    TrashAdd( self.unit.Trash, self.SpinManip )
                end
				
				if not self.SpinManip2 then 
                
                    self.SpinManip2 = CreateRotator(self.unit, 'Rotator2', 'y', nil, -270, -180, -60)
                    TrashAdd( self.unit.Trash, self.SpinManip2 )
                end
                
                self.SpinManip:SetTargetSpeed(320)

                self.SpinManip2:SetTargetSpeed(-320)
                
                AIFArtilleryMiasmaShellWeapon.PlayFxWeaponUnpackSequence(self)
            end,       
		
		
		},
    },
}

TypeClass = BAB2303
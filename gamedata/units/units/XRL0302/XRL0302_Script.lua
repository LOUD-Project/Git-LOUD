local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CMobileKamikazeBombWeapon = import('/lua/cybranweapons.lua').CMobileKamikazeBombWeapon

XRL0302 = Class(CWalkingLandUnit) {

    Weapons = {

        Suicide = Class(CMobileKamikazeBombWeapon) {
        
			OnWeaponFired = function(self)	
				CMobileKamikazeBombWeapon.OnWeaponFired(self)
			end,
        },

    },

    OnScriptBitSet = function(self, bit)

        CWalkingLandUnit.OnScriptBitSet(self, bit)

        if bit == 1 then
            self:GetWeaponByLabel'Suicide':OnWeaponFired()
        end
    end,

}

TypeClass = XRL0302
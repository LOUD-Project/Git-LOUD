local SSeaUnit = import('/lua/seraphimunits.lua').SSeaUnit

local SIFSuthanusArtilleryCannon = import('/lua/seraphimweapons.lua').SIFSuthanusMobileArtilleryCannon
local SAAOlarisCannonWeapon = import('/lua/seraphimweapons.lua').SAAOlarisCannonWeapon

BSS0206 = Class(SSeaUnit) {
    Weapons = {
	
        DeckGun = Class(SIFSuthanusArtilleryCannon) {},
		AAGun = Class(SAAOlarisCannonWeapon) {},
		
    },

    BackWakeEffect = {},
}

TypeClass = BSS0206
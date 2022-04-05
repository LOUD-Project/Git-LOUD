local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local TIFArtilleryWeapon = import('/lua/terranweapons.lua').TIFArtilleryWeapon
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

BEL0308 = Class(TWalkingLandUnit) 
{
    Weapons = {
        MainGun = Class(TIFArtilleryWeapon) {},
		GaussCannons = Class(TDFGaussCannonWeapon) {},
    },
}

TypeClass = BEL0308
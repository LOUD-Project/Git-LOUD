local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Artillery = import('/lua/terranweapons.lua').TIFArtilleryWeapon
local Cannon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

BEL0308 = Class(TWalkingLandUnit) 
{
    Weapons = {
        MainGun = Class(Artillery) {},
		GaussCannons = Class(Cannon) {},
    },
}

TypeClass = BEL0308
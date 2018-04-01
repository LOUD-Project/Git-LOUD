local SSeaUnit = import('/lua/seraphimunits.lua').SSeaUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SDFHeavyQuarnonCannon = SeraphimWeapons.SDFHeavyQuarnonCannon
local SAMElectrumMissileDefense = SeraphimWeapons.SAMElectrumMissileDefense
local SAAOlarisCannonWeapon = SeraphimWeapons.SAAOlarisCannonWeapon
local SIFInainoWeapon = import('/lua/seraphimweapons.lua').SIFInainoWeapon

XSS0302 = Class(SSeaUnit) {
    FxDamageScale = 2,
    DestructionTicks = 400,

    Weapons = {
	
        Turret = Class(SDFHeavyQuarnonCannon) {},
		
        AntiMissile = Class(SAMElectrumMissileDefense) {},
		
        AntiAir = Class(SAAOlarisCannonWeapon) {},
		
        InainoMissiles = Class(SIFInainoWeapon) {},
		
    },
}

TypeClass = XSS0302
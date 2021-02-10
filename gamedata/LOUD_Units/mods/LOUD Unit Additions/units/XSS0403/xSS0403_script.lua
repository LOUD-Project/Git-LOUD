local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SSeaUnit = import('/lua/seraphimunits.lua').SSeaUnit

local SAALosaareAutoCannonWeapon = SeraphimWeapons.SAALosaareAutoCannonWeapon
local SDFExperimentalPhasonProj = SeraphimWeapons.SDFExperimentalPhasonProj
local SAMElectrumMissileDefense = SeraphimWeapons.SAMElectrumMissileDefense

XSS0403 = Class(SSeaUnit) {

    Weapons = {
	
		AAGun = Class(SAALosaareAutoCannonWeapon) {},
        GroundGun = Class(SDFExperimentalPhasonProj) {},
		TMD = Class(SAMElectrumMissileDefense) {},
		
    },

    BackWakeEffect = {},
}

TypeClass = XSS0403

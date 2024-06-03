local SSeaUnit = import('/lua/seraphimunits.lua').SSeaUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SAALosaareAutoCannonWeapon = SeraphimWeapons.SAALosaareAutoCannonWeapon
local SDFExperimentalPhasonProj = SeraphimWeapons.SDFExperimentalPhasonProj
local SAMElectrumMissileDefense = SeraphimWeapons.SAMElectrumMissileDefense

SeraphimWeapons = nil

XSS0403 = Class(SSeaUnit) {

    Weapons = {
	
		AAGun = Class(SAALosaareAutoCannonWeapon) {},

        GroundGun = Class(SDFExperimentalPhasonProj) {},

		TMD = Class(SAMElectrumMissileDefense) {},
    },

}

TypeClass = XSS0403

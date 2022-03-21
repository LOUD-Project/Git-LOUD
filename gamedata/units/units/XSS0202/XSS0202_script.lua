local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local SSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local SLaanseMissileWeapon = SeraphimWeapons.SLaanseMissileWeapon
local SAAOlarisCannonWeapon = SeraphimWeapons.SAAOlarisCannonWeapon
local SAAShleoCannonWeapon = SeraphimWeapons.SAAShleoCannonWeapon
local SAMElectrumMissileDefense = SeraphimWeapons.SAMElectrumMissileDefense

XSS0202 = Class(SSeaUnit) {
    Weapons = {
        Missile = Class(SLaanseMissileWeapon) {},
		RightAAGun = Class(SAAShleoCannonWeapon) {},
		LeftAAGun = Class(SAAOlarisCannonWeapon) {},
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },

    BackWakeEffect = {},
}

TypeClass = XSS0202
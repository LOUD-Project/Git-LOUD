local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SAALosaareAutoCannonWeapon    = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeapon
local SAMElectrumMissileDefense     = import('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

SSL0320 = Class(SLandUnit) {

    Weapons = {
        AntiMissile     = Class(SAMElectrumMissileDefense) {},
        AAMissiles      = Class(SAALosaareAutoCannonWeapon) {},
    },

}

TypeClass = SSL0320

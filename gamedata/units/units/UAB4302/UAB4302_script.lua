local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AAMSaintWeapon = import('/lua/aeonweapons.lua').AAMSaintWeapon
local nukeFiredOnGotTarget = false

UAB4302 = Class(AStructureUnit) {

    Weapons = {

        MissileRack = Class(AAMSaintWeapon) {},
		MissileRack2 = Class(AAMSaintWeapon) {},
    },
}

TypeClass = UAB4302
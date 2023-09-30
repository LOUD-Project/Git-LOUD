local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SIFHuAntiNukeWeapon = import('/lua/seraphimweapons.lua').SIFHuAntiNukeWeapon
local nukeFiredOnGotTarget = false

XSB4302 = Class(SStructureUnit) {

    Weapons = {
        MissileRack = Class(SIFHuAntiNukeWeapon) {},
		MissileRack2 = Class(SIFHuAntiNukeWeapon) {},
    },
}

TypeClass = XSB4302
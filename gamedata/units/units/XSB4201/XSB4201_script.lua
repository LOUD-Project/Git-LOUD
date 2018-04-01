local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit

local SAMElectrumMissileDefense = import('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

XSB4201 = Class(SStructureUnit) {
    Weapons = {
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },
}

TypeClass = XSB4201


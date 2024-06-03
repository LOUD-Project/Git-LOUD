local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFCannonOblivionWeapon = import('/lua/aeonweapons.lua').ADFCannonOblivionWeapon02
local SAMElectrumMissileDefense = import ('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

SAL0401 = Class(ALandUnit) {
    Weapons = {
        MainGun     = Class(ADFCannonOblivionWeapon) {},
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },
}
TypeClass = SAL0401

local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local WeaponsFile = import('/lua/aeonweapons.lua')

local ADFCannonOblivionWeapon = WeaponsFile.ADFCannonOblivionWeapon02
local SAMElectrumMissileDefense = import ('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

SAL0401 = Class(ALandUnit) {
    Weapons = {
        MainGun = Class(ADFCannonOblivionWeapon) {},
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },
}
TypeClass = SAL0401

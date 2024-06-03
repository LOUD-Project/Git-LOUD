local ALandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFCannonOblivionWeapon = import('/lua/aeonweapons.lua').ADFCannonOblivionWeapon

SAL0311 = Class(ALandUnit) {

    Weapons = {
        MainGun = Class(ADFCannonOblivionWeapon) {FxChargeMuzzleFlashScale = 0.3}
    },
}

TypeClass = SAL0311

local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFQuantumAutogunWeapon = import('/lua/aeonweapons.lua').ADFQuantumAutogunWeapon

XAL0203 = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(ADFQuantumAutogunWeapon) {}
    },
}
TypeClass = XAL0203
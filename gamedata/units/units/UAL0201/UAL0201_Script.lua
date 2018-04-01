
local AHoverLandUnit = import('/lua/aeonunits.lua').AHoverLandUnit
local ADFDisruptorCannonWeapon = import('/lua/aeonweapons.lua').ADFDisruptorCannonWeapon

UAL0201 = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(ADFDisruptorCannonWeapon) {}
    },
}
TypeClass = UAL0201


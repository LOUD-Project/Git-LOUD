local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFDisruptorWeapon = import('/lua/aeonweapons.lua').ADFDisruptorWeapon
local ADFCannonQuantumWeapon = import('/lua/aeonweapons.lua').ADFCannonQuantumWeapon

BAL0310 = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(ADFDisruptorWeapon) {},
        SideGuns = Class(ADFCannonQuantumWeapon) {},
    },
}

TypeClass = BAL0310
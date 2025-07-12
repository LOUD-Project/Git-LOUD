local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local Disruptor = import('/lua/aeonweapons.lua').ADFDisruptorWeapon
local Cannon = import('/lua/aeonweapons.lua').ADFCannonQuantumWeapon

BAL0310 = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(Disruptor) {},
        SideGuns = Class(Cannon) {},
    },
}

TypeClass = BAL0310
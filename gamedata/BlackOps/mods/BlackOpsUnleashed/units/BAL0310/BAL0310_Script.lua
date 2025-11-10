local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local Disruptor = import('/lua/aeonweapons.lua').ADFDisruptorWeapon
local Cannon = import('/lua/aeonweapons.lua').ADFCannonQuantumWeapon
local AANDepthChargeBombWeapon      = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

BAL0310 = Class(AHoverLandUnit) {
    Weapons = {
        MainGun = Class(Disruptor) {},
        SideGuns = Class(Cannon) {},
        DepthCharge = Class(AANDepthChargeBombWeapon) {},
    },
}

TypeClass = BAL0310
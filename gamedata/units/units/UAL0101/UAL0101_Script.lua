local AHoverLandUnit = import('/lua/defaultunits.lua').MobileUnit

local ADFLaserLightWeapon = import('/lua/aeonweapons.lua').ADFLaserLightWeapon

UAL0101 = Class(AHoverLandUnit) {
    Weapons = {
        LaserTurret = Class(ADFLaserLightWeapon) {}
    },
}

TypeClass = UAL0101

local AHoverLandUnit = import('/lua/aeonunits.lua').AHoverLandUnit
local ADFLaserLightWeapon = import('/lua/aeonweapons.lua').ADFLaserLightWeapon

UAL0101 = Class(AHoverLandUnit) {
    Weapons = {
        LaserTurret = Class(ADFLaserLightWeapon) {}
    },
}

TypeClass = UAL0101
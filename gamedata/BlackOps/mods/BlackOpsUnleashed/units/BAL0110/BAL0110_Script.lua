local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local ADFSonicPulsarWeapon = import('/lua/aeonweapons.lua').ADFSonicPulsarWeapon

BAL0110 = Class(AWalkingLandUnit) {
    Weapons = {
        ArmLaserTurret = Class(ADFSonicPulsarWeapon) {}
    },
}

TypeClass = BAL0110
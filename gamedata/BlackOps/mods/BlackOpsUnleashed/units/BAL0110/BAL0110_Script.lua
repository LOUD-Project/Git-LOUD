local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local ADFSonicPulsarWeapon = import('/lua/aeonweapons.lua').ADFSonicPulsarWeapon

BAL0110 = Class(AWalkingLandUnit) {
    Weapons = {
        ArmLaserTurret = Class(ADFSonicPulsarWeapon) {}
    },
}

TypeClass = BAL0110
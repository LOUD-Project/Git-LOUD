
local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit
local ADFSonicPulsarWeapon = import('/lua/aeonweapons.lua').ADFSonicPulsarWeapon

UAL0106 = Class(AWalkingLandUnit) {
    Weapons = {
        ArmLaserTurret = Class(ADFSonicPulsarWeapon) {}
    },

}


TypeClass = UAL0106
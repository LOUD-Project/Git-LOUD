local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local ADFSonicPulsarWeapon = import('/lua/aeonweapons.lua').ADFSonicPulsarWeapon

UAL0106 = Class(AWalkingLandUnit) {
    Weapons = {
        ArmLaserTurret = Class(ADFSonicPulsarWeapon) {}
    },

}


TypeClass = UAL0106
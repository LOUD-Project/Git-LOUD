local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Pulsar = import('/lua/aeonweapons.lua').ADFSonicPulsarWeapon

BAL0110 = Class(AWalkingLandUnit) {
    Weapons = {
        ArmLaserTurret = Class(Pulsar) {}
    },
}

TypeClass = BAL0110
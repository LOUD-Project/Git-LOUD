local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CAMEMPMissileWeapon = import('/lua/cybranweapons.lua').CAMEMPMissileWeapon

SAL0321 = Class(AWalkingLandUnit) {
    Weapons = {
        MissileRack = Class(CAMEMPMissileWeapon) {},
    },
}

TypeClass = SAL0321

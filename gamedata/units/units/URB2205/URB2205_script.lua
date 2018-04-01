local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit

local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon

URB2205 = Class(CStructureUnit) {
    Weapons = {
        Turret01 = Class(CANNaniteTorpedoWeapon) {},
    },
}

TypeClass = URB2205
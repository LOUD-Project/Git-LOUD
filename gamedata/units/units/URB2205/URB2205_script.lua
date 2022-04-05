local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon

URB2205 = Class(CStructureUnit) {
    Weapons = {
        Turret01 = Class(CANNaniteTorpedoWeapon) {},
    },
}

TypeClass = URB2205
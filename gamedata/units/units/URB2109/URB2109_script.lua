local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon

URB2109 = Class(CStructureUnit) {
    Weapons = {
        Turret01 = Class(CANNaniteTorpedoWeapon) {},
    },
}

TypeClass = URB2109
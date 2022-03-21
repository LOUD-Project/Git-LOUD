local CSubUnit =  import('/lua/defaultunits.lua').SubUnit

local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon
local CDFLaserHeavyWeapon = import('/lua/cybranweapons.lua').CDFLaserHeavyWeapon

URS0203 = Class(CSubUnit) {

    Weapons = {
        MainGun = Class(CDFLaserHeavyWeapon) {},
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
    },

}

TypeClass = URS0203
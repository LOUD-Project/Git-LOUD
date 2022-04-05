local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit
local CWeapons = import('/lua/cybranweapons.lua')

local CDFHeavyDisintegratorWeapon = CWeapons.CDFHeavyDisintegratorWeapon
local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon
local CIFSmartCharge = import('/lua/cybranweapons.lua').CIFSmartCharge

XRL0305 = Class(CWalkingLandUnit)
{
    Weapons = {
        Disintigrator = Class(CDFHeavyDisintegratorWeapon) {},
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
        AntiTorpedo = Class(CIFSmartCharge) {},
    },
}

TypeClass = XRL0305
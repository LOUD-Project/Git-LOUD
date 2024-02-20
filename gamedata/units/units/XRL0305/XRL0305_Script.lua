local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AeonWeapons = import('/lua/aeonweapons.lua')
local CWeapons = import('/lua/cybranweapons.lua')

local CDFHeavyDisintegratorWeapon = CWeapons.CDFHeavyDisintegratorWeapon
local CANNaniteTorpedoWeapon = import('/lua/cybranweapons.lua').CANNaniteTorpedoWeapon

local AntiTorp = AeonWeapons.AIFQuasarAntiTorpedoWeapon

XRL0305 = Class(CWalkingLandUnit)
{
    Weapons = {

        Disintigrator = Class(CDFHeavyDisintegratorWeapon) {},

        Torpedo = Class(CANNaniteTorpedoWeapon) {},

        AntiTorpedo = Class(AntiTorp) {},
    },
}

TypeClass = XRL0305
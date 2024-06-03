local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CDFHvyProtonCannonWeapon          = CybranWeaponsFile.CDFHvyProtonCannonWeapon
local CDFHeavyMicrowaveLaserGenerator   = CybranWeaponsFile.CDFHeavyMicrowaveLaserGeneratorCom
local CAABurstCloudFlakArtilleryWeapon  = CybranWeaponsFile.CAABurstCloudFlakArtilleryWeapon

CybranWeaponsFile = nil

WRL0404 = Class(CWalkingLandUnit) {

    Weapons = {
        MainGun = Class(CDFHvyProtonCannonWeapon) {},
		
        RightLaserTurret = Class(CDFHeavyMicrowaveLaserGenerator) {},
        LeftLaserTurret = Class(CDFHeavyMicrowaveLaserGenerator) {},
		
        AAGun1 = Class(CAABurstCloudFlakArtilleryWeapon) {},
        AAGun2 = Class(CAABurstCloudFlakArtilleryWeapon) {},
        AAGun3 = Class(CAABurstCloudFlakArtilleryWeapon) {},
        AAGun4 = Class(CAABurstCloudFlakArtilleryWeapon) {},
    },
}

TypeClass = WRL0404
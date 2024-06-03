local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AWeapons = import('/lua/aeonweapons.lua')

local ADFLaserHighIntensityWeapon   = AWeapons.ADFLaserHighIntensityWeapon
local ADFCannonOblivionWeapon       = AWeapons.ADFCannonOblivionWeapon
local ADFQuantumAutogunWeapon       = AWeapons.ADFQuantumAutogunWeapon
local AAAZealotMissileWeapon        = AWeapons.AAAZealotMissileWeapon

AWeapons = nil

WAL4404 = Class(AWalkingLandUnit) {

    Weapons = {
    
        ChinGun     = Class(ADFLaserHighIntensityWeapon) {},
        
		Arm         = Class(ADFCannonOblivionWeapon) {},  

		TopCannon   = Class(ADFQuantumAutogunWeapon) {},
        
		AAMissile   = Class(AAAZealotMissileWeapon) {},
    }, 
}

TypeClass = WAL4404
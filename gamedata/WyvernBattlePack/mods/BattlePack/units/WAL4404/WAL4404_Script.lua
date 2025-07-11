local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local AWeapons = import('/lua/aeonweapons.lua')

local Laser     = AWeapons.ADFLaserHighIntensityWeapon
local Cannon    = AWeapons.ADFCannonOblivionWeapon
local Autogun   = AWeapons.ADFQuantumAutogunWeapon
local AA        = AWeapons.AAAZealotMissileWeapon

AWeapons = nil

WAL4404 = Class(AWalkingLandUnit) {

    Weapons = {
    
        ChinGun     = Class(Laser) {},
        
		Arm         = Class(Cannon) {},  

		TopCannon   = Class(Autogun) {},
        
		AAMissile   = Class(AA) {},
    }, 
}

TypeClass = WAL4404
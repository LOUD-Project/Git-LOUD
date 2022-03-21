local AWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')
local AWeapons = import('/lua/aeonweapons.lua')

local ADFCannonOblivionWeapon = AWeapons.ADFCannonOblivionWeapon
local ADFQuantumAutogunWeapon = AWeapons.ADFQuantumAutogunWeapon
local AAAZealotMissileWeapon = AWeapons.AAAZealotMissileWeapon

local ADFLaserHighIntensityWeapon = import('/lua/aeonweapons.lua').ADFLaserHighIntensityWeapon

WAL4404 = Class(AWalkingLandUnit) {

    Weapons = {
    
        ChinGun = Class(ADFLaserHighIntensityWeapon) {},
        
		Arm = Class(ADFCannonOblivionWeapon) {},  

		TopCannon = Class(ADFQuantumAutogunWeapon) {},
        
		AntiAirMissiles01 = Class(AAAZealotMissileWeapon) {},

    }, 
}

TypeClass = WAL4404
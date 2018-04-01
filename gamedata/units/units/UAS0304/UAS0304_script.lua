local ASubUnit = import('/lua/aeonunits.lua').ASubUnit

local WeaponFile = import('/lua/aeonweapons.lua')

local AIFMissileTacticalSerpentineWeapon = WeaponFile.AIFMissileTacticalSerpentineWeapon
local AIFQuantumWarhead = WeaponFile.AIFQuantumWarhead
local AIFQuasarAntiTorpedoWeapon = WeaponFile.AIFQuasarAntiTorpedoWeapon

UAS0304 = Class(ASubUnit) {
	
    Weapons = {
	
        CruiseMissiles = Class(AIFMissileTacticalSerpentineWeapon) {},
        NukeMissiles = Class(AIFQuantumWarhead) {},
        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
		
    },
	
}

TypeClass = UAS0304


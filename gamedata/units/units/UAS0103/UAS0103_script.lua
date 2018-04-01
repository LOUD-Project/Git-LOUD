local ASeaUnit = import('/lua/aeonunits.lua').ASeaUnit
local AeonWeapons = import('/lua/aeonweapons.lua')

local ADFCannonQuantumWeapon = AeonWeapons.ADFCannonQuantumWeapon
local AIFQuasarAntiTorpedoWeapon = AeonWeapons.AIFQuasarAntiTorpedoWeapon

local AQuantumCannonMuzzle02 = import('/lua/EffectTemplates.lua').AQuantumCannonMuzzle02

UAS0103 = Class(ASeaUnit) {

    Weapons = {
	
        MainGun = Class(ADFCannonQuantumWeapon) { FxMuzzleFlash = AQuantumCannonMuzzle02 },

        AntiTorpedo01 = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
	
}

TypeClass = UAS0103

local SeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')

local ADFCannonQuantumWeapon        = AeonWeapons.ADFCannonQuantumWeapon
local AIFQuasarAntiTorpedoWeapon    = AeonWeapons.AIFQuasarAntiTorpedoWeapon

AeonWeapons = nil

local AQuantumCannonMuzzle02 = import('/lua/EffectTemplates.lua').AQuantumCannonMuzzle02

UAS0103 = Class(SeaUnit) {

    Weapons = {
	
        DeckGuns = Class(ADFCannonQuantumWeapon) { FxMuzzleFlash = AQuantumCannonMuzzle02 },

        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
	
}

TypeClass = UAS0103

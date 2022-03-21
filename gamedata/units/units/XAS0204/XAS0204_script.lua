local ASubUnit =  import('/lua/defaultunits.lua').SubUnit

local AANChronoTorpedoWeapon = import('/lua/aeonweapons.lua').AANChronoTorpedoWeapon
local AIFQuasarAntiTorpedoWeapon = import('/lua/aeonweapons.lua').AIFQuasarAntiTorpedoWeapon

XAS0204 = Class(ASubUnit) {

    Weapons = {
	
        Torpedo = Class(AANChronoTorpedoWeapon) {},
        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},

    },
}

TypeClass = XAS0204
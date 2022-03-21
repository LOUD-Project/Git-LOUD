local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')

local ADFCannonOblivionWeapon = AeonWeapons.ADFCannonOblivionWeapon
local AANChronoTorpedoWeapon = AeonWeapons.AANChronoTorpedoWeapon
local AIFQuasarAntiTorpedoWeapon = AeonWeapons.AIFQuasarAntiTorpedoWeapon


UAS0201 = Class(ASeaUnit) {

    Weapons = {
        FrontTurret = Class(ADFCannonOblivionWeapon) {},
        Torpedo = Class(AANChronoTorpedoWeapon) {},
        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
}

TypeClass = UAS0201
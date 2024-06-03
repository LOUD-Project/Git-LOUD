local ASeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')

local ADFCannonOblivionWeapon       = AeonWeapons.ADFCannonOblivionWeapon
local AANChronoTorpedoWeapon        = AeonWeapons.AANChronoTorpedoWeapon
local AIFQuasarAntiTorpedoWeapon    = AeonWeapons.AIFQuasarAntiTorpedoWeapon

AeonWeapons = nil


UAS0201 = Class(ASeaUnit) {

    Weapons = {
        FrontTurret = Class(ADFCannonOblivionWeapon) {},

        Torpedo = Class(AANChronoTorpedoWeapon) {},

        AntiTorpedo1 = Class(AIFQuasarAntiTorpedoWeapon) {},
        AntiTorpedo2 = Class(AIFQuasarAntiTorpedoWeapon) {},
        AntiTorpedo3 = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
}

TypeClass = UAS0201
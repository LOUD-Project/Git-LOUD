local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local WeaponFile = import('/lua/terranweapons.lua')

local TANTorpedoAngler = WeaponFile.TANTorpedoAngler
local TIFSmartCharge = WeaponFile.TIFSmartCharge

XES0102 = Class(TSeaUnit) {

    Weapons = {
        Torpedo = Class(TANTorpedoAngler) {},
        AntiTorpedo = Class(TIFSmartCharge) {},
    },    
}

TypeClass = XES0102
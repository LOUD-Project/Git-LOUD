local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CIFSmartCharge = import('/lua/cybranweapons.lua').CIFSmartCharge

XRS0205 = Class(CSeaUnit) {

    Weapons = {
        AntiTorpedo = Class(CIFSmartCharge) {},
    },
    
}

TypeClass = XRS0205
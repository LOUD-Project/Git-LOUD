local CSeaUnit = import('/lua/cybranunits.lua').CSeaUnit
local CIFSmartCharge = import('/lua/cybranweapons.lua').CIFSmartCharge

XRS0205 = Class(CSeaUnit) {

    Weapons = {
        AntiTorpedo = Class(CIFSmartCharge) {},
    },
    
}

TypeClass = XRS0205
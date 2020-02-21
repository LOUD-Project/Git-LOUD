local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TANTorpedoLandWeapon = WeaponsFile.TANTorpedoLandWeapon
local TIFSmartCharge = WeaponsFile.TIFSmartCharge

WEB0404 = Class(TStructureUnit) {

    UpsideDown = false,

    Weapons = {
        Turret = Class(TDFGaussCannonWeapon) {},

        Torpedo = Class(TANTorpedoLandWeapon) {},
        
        AntiTorpedo = Class(TIFSmartCharge) {},
    },
}

TypeClass = WEB0404
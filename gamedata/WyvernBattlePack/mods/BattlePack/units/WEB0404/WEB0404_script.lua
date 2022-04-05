local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TANTorpedoLandWeapon = WeaponsFile.TANTorpedoLandWeapon
local TIFSmartCharge = WeaponsFile.TIFSmartCharge

WEB0404 = Class(TStructureUnit) {

    Weapons = {
        Turret = Class(TDFGaussCannonWeapon) {},

        Torpedo = Class(TANTorpedoLandWeapon) {},
        
        AntiTorpedo = Class(TIFSmartCharge) {},
    },
}

TypeClass = WEB0404
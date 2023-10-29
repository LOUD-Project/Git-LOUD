local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local TAMPhalanxWeapon = WeaponsFile.TAMPhalanxWeapon
local TDFHiroPlasmaCannon = WeaponsFile.TDFHiroPlasmaCannon
local TANTorpedoAngler = WeaponsFile.TANTorpedoAngler
local TIFSmartCharge = WeaponsFile.TIFSmartCharge

UES0302 = Class(TSeaUnit) {

    Weapons = {
	
        HiroCannon = Class(TDFHiroPlasmaCannon) {},
        AntiTorpedo = Class(TIFSmartCharge) {},
        Torpedo = Class(TANTorpedoAngler) {},
        PhalanxGun = Class(TAMPhalanxWeapon) {},

    },
	
}
TypeClass = UES0302
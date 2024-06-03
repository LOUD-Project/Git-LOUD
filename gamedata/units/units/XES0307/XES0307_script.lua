local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')
local AIFQuasarAntiTorpedoWeapon = AeonWeapons.AIFQuasarAntiTorpedoWeapon

local WeaponsFile = import('/lua/terranweapons.lua')

local TAMPhalanxWeapon      = WeaponsFile.TAMPhalanxWeapon
local TDFHiroPlasmaCannon   = WeaponsFile.TDFHiroPlasmaCannon
local TANTorpedoAngler      = WeaponsFile.TANTorpedoAngler

AeonWeapons = nil
WeaponsFile = nil

UES0302 = Class(TSeaUnit) {

    Weapons = {
	
        HiroCannon = Class(TDFHiroPlasmaCannon) {},
        Torpedo = Class(TANTorpedoAngler) {},
        PhalanxGun = Class(TAMPhalanxWeapon) {},
        AntiTorpedo = Class(AIFQuasarAntiTorpedoWeapon) {},
    },
	
}
TypeClass = UES0302
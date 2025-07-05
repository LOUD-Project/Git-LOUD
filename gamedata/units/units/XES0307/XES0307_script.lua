local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local AeonWeapons = import('/lua/aeonweapons.lua')
local AntiTorpedo = AeonWeapons.AIFQuasarAntiTorpedoWeapon

local WeaponsFile = import('/lua/terranweapons.lua')

local Phalanx   = WeaponsFile.TAMPhalanxWeapon
local Plasma    = WeaponsFile.TDFHiroPlasmaCannon
local Torpedo   = WeaponsFile.TANTorpedoAngler

AeonWeapons = nil
WeaponsFile = nil

UES0302 = Class(TSeaUnit) {

    Weapons = {
	
        HiroCannonF  = Class(Plasma) {},
        HiroCannonB  = Class(Plasma) {},
        Torpedo      = Class(Torpedo) { FxMuzzleFlash = false },
        PhalanxGun   = Class(Phalanx) {},
        AntiTorpedo  = Class(AntiTorpedo) { FxMuzzleFlash = false },
    },
	
}
TypeClass = UES0302
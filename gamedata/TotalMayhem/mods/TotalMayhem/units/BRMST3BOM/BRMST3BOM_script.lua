local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CAAAutocannon             = CybranWeaponsFile.CAAAutocannon
local CDFProtonCannonWeapon     = CybranWeaponsFile.CDFProtonCannonWeapon
local CANNaniteTorpedoWeapon    = CybranWeaponsFile.CANNaniteTorpedoWeapon
local CAMZapperWeapon           = CybranWeaponsFile.CAMZapperWeapon

CybranWeaponsFile = nil

BRMST3BOM = Class(CSeaUnit) {

    Weapons = {
	
        Cannon  = Class(CDFProtonCannonWeapon) {},
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
        AAGun   = Class(CAAAutocannon) {},
        Zapper  = Class(CAMZapperWeapon) {},
		
    },
}
TypeClass = BRMST3BOM
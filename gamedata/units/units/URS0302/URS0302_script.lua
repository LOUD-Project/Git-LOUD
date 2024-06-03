local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CDFProtonCannonWeapon     = CybranWeaponsFile.CDFProtonCannonWeapon
local CAAAutocannon             = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CANNaniteTorpedoWeapon    = CybranWeaponsFile.CANNaniteTorpedoWeapon
local CAMZapperWeapon           = CybranWeaponsFile.CAMZapperWeapon

CybranWeaponsFile = nil

URS0302 = Class(CSeaUnit) {

    Weapons = {
	
        Cannon  = Class(CDFProtonCannonWeapon) {},
        AAGun   = Class(CAAAutocannon) {},
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
        Zapper  = Class(CAMZapperWeapon) {},

    },
}
TypeClass = URS0302
local CSeaUnit = import('/lua/cybranunits.lua').CSeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local CAAAutocannon = CybranWeaponsFile.CAAAutocannon
local CDFProtonCannonWeapon = CybranWeaponsFile.CDFProtonCannonWeapon
local CANNaniteTorpedoWeapon = CybranWeaponsFile.CANNaniteTorpedoWeapon
local CAMZapperWeapon02 = CybranWeaponsFile.CAMZapperWeapon02

URS0302 = Class(CSeaUnit) {

    Weapons = {
	
        Cannon = Class(CDFProtonCannonWeapon) {},
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
        AAGun = Class(CAAAutocannon) {},
        Zapper = Class(CAMZapperWeapon02) {},

    },
}
TypeClass = URS0302
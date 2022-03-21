local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')
local CybranWeaponsFile2 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua')

local XCannonWeapon01 = CybranWeaponsFile2.XCannonWeapon01

local CAAAutocannon = CybranWeaponsFile.CAAAutocannon
local CDFProtonCannonWeapon = CybranWeaponsFile.CDFProtonCannonWeapon
local CANNaniteTorpedoWeapon = CybranWeaponsFile.CANNaniteTorpedoWeapon
local CAMZapperWeapon02 = CybranWeaponsFile.CAMZapperWeapon02

XRS0402= Class(CSeaUnit) {

    Weapons = {
	
        MainCannon = Class(XCannonWeapon01) {},
		
        BackCannon = Class(CDFProtonCannonWeapon) {},
		
        SecondaryCannon = Class(CDFProtonCannonWeapon) {},
		
        AAGun = Class(CAAAutocannon) {},
        Zapper = Class(CAMZapperWeapon02) {},
        Torpedo = Class(CANNaniteTorpedoWeapon) {},
    },
}

TypeClass = XRS0402
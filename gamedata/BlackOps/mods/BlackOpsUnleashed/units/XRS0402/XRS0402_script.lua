local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local XCannonWeapon01 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').XCannonWeapon01

local CAAAutocannon             = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CDFProtonCannonWeapon     = CybranWeaponsFile.CDFProtonCannonWeapon
local CANNaniteTorpedoWeapon    = CybranWeaponsFile.CANNaniteTorpedoWeapon
local CAMZapperWeapon02         = CybranWeaponsFile.CAMZapperWeapon02

CybranWeaponsFile = nil

XRS0402= Class(CSeaUnit) {

    Weapons = {
        MainCannonFront = Class(XCannonWeapon01) {},
        MainCannonBack  = Class(XCannonWeapon01) {},
        BombardmentGun  = Class(CDFProtonCannonWeapon) {},
        SecondaryCannon = Class(CDFProtonCannonWeapon) {},
        AAGun           = Class(CAAAutocannon) {},
        Zapper          = Class(CAMZapperWeapon02) {},
        Torpedo         = Class(CANNaniteTorpedoWeapon) {},
    },
}

TypeClass = XRS0402
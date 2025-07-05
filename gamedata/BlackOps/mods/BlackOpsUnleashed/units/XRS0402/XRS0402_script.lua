local CSeaUnit = import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local XCannon = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').XCannonWeapon01

local AA        = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local Cannon    = CybranWeaponsFile.CDFProtonCannonWeapon
local Torpedo   = CybranWeaponsFile.CANNaniteTorpedoWeapon
local Zapper    = CybranWeaponsFile.CAMZapperWeapon02

CybranWeaponsFile = nil

XRS0402= Class(CSeaUnit) {

    Weapons = {
        MainCannonFront = Class(XCannon) {},
        MainCannonBack  = Class(XCannon) {},
        BombardmentGun  = Class(Cannon) {},
        SecondaryCannon = Class(Cannon) {},
        AAGun           = Class(AA) {},
        Zapper          = Class(Zapper) {},
        Torpedo         = Class(Torpedo) { FxMuzzleFlash = false},
    },
}

TypeClass = XRS0402
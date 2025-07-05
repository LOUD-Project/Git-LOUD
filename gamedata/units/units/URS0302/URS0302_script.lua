local CSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local CybranWeaponsFile = import('/lua/cybranweapons.lua')

local Cannon    = CybranWeaponsFile.CDFProtonCannonWeapon
local AA        = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local Torpedo   = CybranWeaponsFile.CANNaniteTorpedoWeapon
local Zapper    = CybranWeaponsFile.CAMZapperWeapon

CybranWeaponsFile = nil

URS0302 = Class(CSeaUnit) {

    Weapons = {
        CannonF = Class(Cannon) {},
        CannonB = Class(Cannon) {},
        AAF     = Class(AA) {},
        AAB     = Class(AA) {},
        Torpedo = Class(Torpedo) { FxMuzzleFlash = false },
        Zapper  = Class(Zapper) {},
    },
}
TypeClass = URS0302
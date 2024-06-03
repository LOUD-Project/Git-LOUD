local TSeaUnit =  import('/lua/defaultunits.lua').SeaUnit

local TANTorpedoAngler = import('/lua/terranweapons.lua').TANTorpedoAngler

local TorpedoDecoy = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

WeaponFile = nil

XES0102 = Class(TSeaUnit) {

    Weapons = {
        Torpedo = Class(TANTorpedoAngler) { FxMuzzleFlashScale = 0.5, },
        
        AntiTorpedoLeft = Class(TorpedoDecoy) { FxMuzzleFlash = false },
        AntiTorpedoRight = Class(TorpedoDecoy) { FxMuzzleFlash = false },
    },    
}

TypeClass = XES0102
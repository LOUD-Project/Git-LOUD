local CLandUnit = import('/lua/defaultunits.lua').MobileUnit

local CIFArtilleryWeapon = import('/lua/cybranweapons.lua').CIFArtilleryWeapon

URL0304 = Class(CLandUnit) {
    Weapons = {
        MainGun = Class(CIFArtilleryWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/cybran_artillery_muzzle_flash_01_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_flash_02_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',
            },
        }
    },
}

TypeClass = URL0304
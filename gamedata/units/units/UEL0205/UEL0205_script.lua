local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TAAFlakArtilleryCannon = import('/lua/terranweapons.lua').TAAFlakArtilleryCannon

UEL0205 = Class(TLandUnit) {
    Weapons = {
        AAGun = Class(TAAFlakArtilleryCannon) {
            PlayOnlyOneSoundCue = true,
        },
    },
}

TypeClass = UEL0205
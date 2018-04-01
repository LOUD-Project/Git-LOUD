local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit

local CDFParticleCannonWeapon = import('/lua/cybranweapons.lua').CDFParticleCannonWeapon

URB2301 = Class(CStructureUnit) {
    Weapons = {
        MainGun = Class(CDFParticleCannonWeapon) {
            FxMuzzleFlash = {'/effects/emitters/particle_cannon_muzzle_02_emit.bp'},
        },
    },
}

TypeClass = URB2301
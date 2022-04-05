local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TIFCruiseMissileLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileLauncher
local EffectTemplate = import('/lua/EffectTemplates.lua')

UEB2108 = Class(TStructureUnit) {
    Weapons = {
        CruiseMissile = Class(TIFCruiseMissileLauncher) {
            FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchBuilding,
        },

    },
}
TypeClass = UEB2108
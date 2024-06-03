local TStructureUnit = import('/lua/defaultunits.lua').StructureUnit
local TIFCruiseMissileLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileLauncher
local TIFCruiseMissileLaunchBuilding = import('/lua/EffectTemplates.lua').TIFCruiseMissileLaunchBuilding

UEB2108 = Class(TStructureUnit) {
    Weapons = {
        CruiseMissile = Class(TIFCruiseMissileLauncher) { FxMuzzleFlash = TIFCruiseMissileLaunchBuilding },
    },
}
TypeClass = UEB2108
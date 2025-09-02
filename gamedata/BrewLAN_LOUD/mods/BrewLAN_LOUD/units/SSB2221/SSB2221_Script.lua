local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

SSB2221 = Class(MineStructureUnit) {
    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) { FxDeathLand = EffectTemplate.SRifterMobileArtilleryHit },
    },
}
TypeClass = SSB2221

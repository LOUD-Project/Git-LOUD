local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

SEB2221 = Class(MineStructureUnit) {
    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) { FxDeathLand = EffectTemplate.TAPDSHitUnit01,
        },
    },
}
TypeClass = SEB2221

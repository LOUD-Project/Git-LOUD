local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

SSB2220 = Class(MineStructureUnit) {
    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) {
   			FxDeathLand = EffectTemplate.SOtheBombHitUnit,
        },
    },
}
TypeClass = SSB2220

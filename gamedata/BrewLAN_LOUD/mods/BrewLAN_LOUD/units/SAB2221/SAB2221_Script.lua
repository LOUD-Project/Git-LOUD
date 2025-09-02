local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

SAB2221 = Class(MineStructureUnit) {

    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) { FxDeathLand = EffectTemplate.ABombHit01 },
    },
}
TypeClass = SAB2221

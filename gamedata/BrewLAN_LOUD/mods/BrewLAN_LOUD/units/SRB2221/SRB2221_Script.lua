local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

SRB2221 = Class(MineStructureUnit) {

    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) { FxDeathLand = EffectTemplate.CBombHit01, },
    },
}
TypeClass = SRB2221

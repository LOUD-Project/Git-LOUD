local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

SEB2220 = Class(MineStructureUnit) {

    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) {},
    },
}

TypeClass = SEB2220

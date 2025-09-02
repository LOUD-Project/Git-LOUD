local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

SAB2220 = Class(MineStructureUnit) {

    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) {},
    },
    
}
TypeClass = SAB2220

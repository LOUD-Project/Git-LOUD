local MineStructureUnit = import('/lua/defaultunits.lua').MineStructureUnit

local EffectTemplate    = import('/lua/EffectTemplates.lua')

SSB2222 = Class(MineStructureUnit) {

    Weapons = {
    
        Suicide = Class(MineStructureUnit.Weapons.Suicide) { FxDeathLand = EffectTemplate.TAntiMatterShellHit01,},
        
        DeathWeapon = Class(MineStructureUnit.Weapons.Suicide) { FxDeathLand = EffectTemplate.TAPDSHitUnit01,},
    },

}

TypeClass = SSB2222

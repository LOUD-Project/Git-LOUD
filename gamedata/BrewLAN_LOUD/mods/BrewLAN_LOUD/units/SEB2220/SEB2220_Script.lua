--------------------------------------------------------------------------------
--  Summary  :  UEF Stationary Explosive Script
--------------------------------------------------------------------------------
local MineStructureUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/defaultunits.lua').MineStructureUnit
local EffectTemplate = import('/lua/EffectTemplates.lua')

SEB2220 = Class(MineStructureUnit) {
    Weapons = {
        Suicide = Class(MineStructureUnit.Weapons.Suicide) {
   			FxDeathLand = EffectTemplate.TSmallYieldNuclearBombHit01,
        },
    },
}
TypeClass = SEB2220

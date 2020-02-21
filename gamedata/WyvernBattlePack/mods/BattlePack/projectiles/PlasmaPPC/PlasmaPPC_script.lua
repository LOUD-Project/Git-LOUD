# an energy proj based on EnergyProj1 but with smaller effects

local PlasmaPPC = import('/mods/BattlePack/lua/BattlePackprojectiles.lua').NEnergy

PlasmaPPC = Class(PlasmaPPC) {
    PolyTrailScale = 1.5, 
    FxTrailScale = 1.5,
    FxNoneHitScale = 1.5,
    FxUnderWaterHitScale = 1.5,
    FxWaterHitScale = 1.5,
    FxLandHitScale = 1.5,
    FxUnitHitScale = 1.5,
}

TypeClass = PlasmaPPC

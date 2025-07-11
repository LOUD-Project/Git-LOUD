-- an energy proj based on EnergyProj1 but with smaller effects

local PlasmaPPC = import('/mods/BattlePack/lua/BattlePackprojectiles.lua').NEnergy

PlasmaPPC = Class(PlasmaPPC) {

    PolyTrailScale = 1.3, 
    FxTrailScale = 1.3,

    FxNoneHitScale = 0.6,
    FxWaterHitScale = 0.6,
    FxLandHitScale = 0.75,
    FxUnitHitScale = 1,

}

TypeClass = PlasmaPPC


local SWallStructureUnit = import('/lua/defaultunits.lua').WallStructureUnit

local CardinalWallUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/walls.lua').CardinalWallUnit

SWallStructureUnit = CardinalWallUnit( SWallStructureUnit )

SSB5210 = Class(SWallStructureUnit) {}

TypeClass = SSB5210

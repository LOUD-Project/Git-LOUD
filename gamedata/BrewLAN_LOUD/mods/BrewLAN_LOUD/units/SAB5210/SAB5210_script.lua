local AWallStructureUnit = import('/lua/aeonunits.lua').AWallStructureUnit

local CardinalWallUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/walls.lua').CardinalWallUnit

AWallStructureUnit = CardinalWallUnit( AWallStructureUnit ) 

SAB5210 = Class(AWallStructureUnit) {}

TypeClass = SAB5210

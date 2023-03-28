local AWallStructureUnit = import('/lua/defaultunits.lua').WallStructureUnit

local CardinalWallUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/walls.lua').CardinalWallUnit

AWallStructureUnit = CardinalWallUnit( AWallStructureUnit ) 

SAB5210 = Class(AWallStructureUnit) {}

TypeClass = SAB5210

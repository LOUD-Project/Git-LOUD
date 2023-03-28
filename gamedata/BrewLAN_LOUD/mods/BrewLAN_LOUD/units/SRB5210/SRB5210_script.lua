local CWallStructureUnit = import('/lua/defaultunits.lua').WallStructureUnit

local CardinalWallUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/walls.lua').CardinalWallUnit

CWallStructureUnit = CardinalWallUnit( CWallStructureUnit )

SRB5210 = Class(CWallStructureUnit) {}

TypeClass = SRB5210

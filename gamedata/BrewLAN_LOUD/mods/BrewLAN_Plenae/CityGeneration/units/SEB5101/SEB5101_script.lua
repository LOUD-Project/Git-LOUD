--------------------------------------------------------------------------------
-- UEF Wall: With cordinal scripting
--------------------------------------------------------------------------------
local TWallStructureUnit = import('/lua/defaultunits.lua').WallStructureUnit
local CardinalWallUnit = import(import( '/lua/game.lua' ).BrewLANPath() .. '/lua/walls.lua').CardinalWallUnit
--------------------------------------------------------------------------------
TWallStructureUnit = CardinalWallUnit( TWallStructureUnit )

SEB5210 = Class(TWallStructureUnit) {}

TypeClass = SEB5210

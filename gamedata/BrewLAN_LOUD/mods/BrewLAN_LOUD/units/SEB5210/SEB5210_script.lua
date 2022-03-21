local TWallStructureUnit = import('/lua/terranunits.lua').TWallStructureUnit

local CardinalWallUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/walls.lua').CardinalWallUnit

TWallStructureUnit = CardinalWallUnit( TWallStructureUnit )

SEB5210 = Class(TWallStructureUnit) {}

TypeClass = SEB5210

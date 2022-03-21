local TWallStructureUnit = import('/lua/terranunits.lua').TWallStructureUnit

local CardinalWallUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/walls.lua').CardinalWallUnit

local GateWallUnit = import(import( '/lua/game.lua' ).BrewLANLOUDPath() .. '/lua/walls.lua').GateWallUnit

TWallStructureUnit = CardinalWallUnit( TWallStructureUnit ) 
TWallStructureUnit = GateWallUnit( TWallStructureUnit )

SEB5311 = Class(TWallStructureUnit) {}

TypeClass = SEB5311

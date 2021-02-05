local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

VEB2302 = Class(TStructureUnit) {

    Weapons = {
	
       MissileRack01 = Class(TSAMLauncher) {},
	   
        },
		
    }

TypeClass = VEB2302
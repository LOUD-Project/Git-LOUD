local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit
local TAALinkedRailgun = import('/lua/terranweapons.lua').TAALinkedRailgun

UEB2104 = Class(TStructureUnit) {

    Weapons = {
	
        AAGun = Class(TAALinkedRailgun) {},
		
    },
	
}

TypeClass = UEB2104

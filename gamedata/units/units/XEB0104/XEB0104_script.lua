local TPodTowerUnit = import('/lua/terranunits.lua').TConstructionUnit
local StructureUnit = import('/lua/defaultunits.lua').StructureUnit

XEB0104 = Class(TPodTowerUnit) {

    CreateTarmac = function( self, albedo, normal, glow, orientation, specTarmac, lifetime )
    
        StructureUnit.CreateTarmac( self, albedo, normal, glow, orientation, specTarmac, lifetime )
        
    end,
    
    LaunchUpgradeThread = function( finishedUnit, aiBrain )
    
        StructureUnit.LaunchUpgradeThread( finishedUnit, aiBrain )
        
    end,

}

TypeClass = XEB0104
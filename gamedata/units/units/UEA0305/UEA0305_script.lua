local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TWeapons = import('/lua/terranweapons.lua')

local TDFHeavyPlasmaCannonWeapon    = TWeapons.TDFHeavyPlasmaCannonWeapon
local TAALinkedRailgun        = TWeapons.TAALinkedRailgun

TWeapons = nil

UEA0305 = Class(TAirUnit) {
    
    EngineRotateBones = {'Jet_Front', 'Jet_Back',},
    BeamExhaustCruise = '/effects/emitters/gunship_thruster_beam_01_emit.bp',
    BeamExhaustIdle = '/effects/emitters/gunship_thruster_beam_02_emit.bp',
    
    Weapons = {
	
        Plasma = Class(TDFHeavyPlasmaCannonWeapon) {},
        AAGun = Class(TAALinkedRailgun) {},
		
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        TAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.EngineManipulators = {}
		
		local LOUDINSERT = table.insert
		local CreateThrustController = CreateThrustController

        -- create the engine thrust manipulators
        for _, value in self.EngineRotateBones do
            LOUDINSERT(self.EngineManipulators, CreateThrustController(self, 'Thruster', value))
        end

        -- set up the thursting arcs for the engines
        for _,value in self.EngineManipulators do
            --                       XMAX, XMIN, YMAX, YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
            value:SetThrustingParam( -0.0, 0.0, -0.25, 0.25, -0.1, 1.0,   1.0,      0.25 )
        end

        for _, v in self.EngineManipulators do
            self.Trash:Add(v)
        end

    end,

}
TypeClass = UEA0305
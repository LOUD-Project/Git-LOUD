local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local TDFRiotWeapon = import('/lua/terranweapons.lua').TDFPlasmaCannonWeapon

local LOUDINSERT = table.insert

UEA0203 = Class(TAirUnit) {

    EngineRotateBones = {'Jet_Front', 'Jet_Back',},

    Weapons = {
        Turret01 = Class(TDFRiotWeapon) { FxMuzzleFlashScale = 0.2 },
    },

    OnStopBeingBuilt = function(self,builder,layer)
	
        TAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.EngineManipulators = {}

        -- create the engine thrust manipulators
        for key, value in self.EngineRotateBones do
            LOUDINSERT(self.EngineManipulators, CreateThrustController(self, "thruster", value))
        end

        -- set up the thursting arcs for the engines
        for key,value in self.EngineManipulators do
		
            #                          XMAX, XMIN, YMAX,YMIN, ZMAX,ZMIN, TURNMULT, TURNSPEED
            value:SetThrustingParam( -0.0, 0.0, -0.25, 0.25, -0.1, 0.1, 1.0,      0.25 )
			
        end
        
        for k, v in self.EngineManipulators do
		
            self.Trash:Add(v)
			
        end

    end,
    
    OnTransportAttach = function(self, attachBone, unit)
		
        TAirUnit.OnTransportAttach(self, attachBone, unit)
		
        if not self.AttachedUnits then
		
            self.AttachedUnits = {}
			
        end
		
        LOUDINSERT( self.AttachedUnits, unit )
    end,
    
    OnTransportDetach = function(self, attachBone, unit)
		
        TAirUnit.OnTransportDetach( self, attachBone, unit )
		
        if self.AttachedUnits then
		
            for k,v in self.AttachedUnits do
			
                if v == unit then
				
                    self.AttachedUnits = nil
                    
					break
					
                end 
				
			end
			
        end
		
    end,
    
    DestroyedOnTransport = function(self)
		
        if self.AttachedUnits then
		
            for k,v in self.AttachedUnits do
			
                v:Destroy()
				
            end
			
        end
		
		self.AttachedUnits = nil
		
    end,
}

TypeClass = UEA0203
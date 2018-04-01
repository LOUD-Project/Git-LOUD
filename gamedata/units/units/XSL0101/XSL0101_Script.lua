local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit

local SDFPhasicAutoGunWeapon = import('/lua/seraphimweapons.lua').SDFPhasicAutoGunWeapon

XSL0101 = Class(SWalkingLandUnit) {

    Weapons = {
		LaserTurret = Class(SDFPhasicAutoGunWeapon) {
		
			OnWeaponFired = function(self, target)
			
				SDFPhasicAutoGunWeapon.OnWeaponFired(self, target)
				ChangeState( self.unit, self.unit.VisibleState )
				
			end,
			
			OnLostTarget = function(self)
			
				SDFPhasicAutoGunWeapon.OnLostTarget(self)
				
				if not self.unit:IsUnitState('Busy') then
				    ChangeState( self.unit, self.unit.InvisState )
				end

			end,
        },
    },
    
    OnStopBeingBuilt = function(self, builder, layer)
	
        SWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        
        -- This starts enabled, so before going to InvisState, disable it..
		self:DisableUnitIntel('Cloak')
		self.Cloaked = false
		
        ChangeState( self, self.InvisState ) # If spawned in we want the unit to be invis, normally the unit will immediately start moving
    end,
    
    InvisState = State() {
	
        Main = function(self)
		
            self.Cloaked = false
			
            local bp = self:GetBlueprint()
			
            if bp.Intel.StealthWaitTime then
                WaitSeconds( bp.Intel.StealthWaitTime )
            end
			
			self:EnableUnitIntel('Cloak')
			self.Cloaked = true
			
			self:SetMesh(bp.Display.CloakMeshBlueprint, true)
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
		
            if new != 'Stopped' then
                ChangeState( self, self.VisibleState )
            end
			
            SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
    
    VisibleState = State() {
	
        Main = function(self)

		    self:DisableUnitIntel('Cloak')
			
			self:SetMesh(self:GetBlueprint().Display.MeshBlueprint, true)
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
		
            if new == 'Stopped' then
                ChangeState( self, self.InvisState )
            end
			
            SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
}
TypeClass = XSL0101
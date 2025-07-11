local SSubUnit =  import('/lua/defaultunits.lua').SubUnit

local Torpedo   = import('/lua/seraphimweapons.lua').SANUallCavitationTorpedo
local Cannon    = import('/lua/seraphimweapons.lua').SAALosaareAutoCannonWeaponSeaUnit

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

XSS0304 = Class(SSubUnit) {

    Weapons = {
	
        Torpedo = Class(Torpedo) {
  
            FxMuzzleFlash = false,
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(64)
                
                Torpedo.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( Torpedo.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(52)
                
                    Torpedo.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(64) self:ChangeMinRadius(60) WaitTicks(37) self:ChangeMaxRadius(64) self:ChangeMinRadius(8) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },  
        },
        AA      = Class(Cannon) {},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        SSubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitters
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
        end

		
        if layer == 'Water' then
            ChangeState( self, self.OpenState )
        else
            ChangeState( self, self.ClosedState )
        end
        
        self.DeathWeaponEnabled = true

        -- setup callbacks to engage sonar stealth when not moving
        local StartMoving = function(unit)
            unit:DisableIntel('SonarStealth')
        end
        
        local StopMoving = function(unit)
            unit:EnableIntel('SonarStealth')
        end
        
        self:AddOnHorizontalStartMoveCallback( StartMoving )
        self:AddOnHorizontalStopMoveCallback( StopMoving )

    end,

    OnLayerChange = function( self, new, old )
	
        SSubUnit.OnLayerChange(self, new, old)
		
        if new == 'Water' then
            ChangeState( self, self.OpenState )
        elseif new == 'Sub' then
            ChangeState( self, self.ClosedState )
        end
    end,
    
    OpenState = State() {
	
        Main = function(self)
		
            if not self.CannonAnim then
                self.CannonAnim = CreateAnimator(self)
                self.Trash:Add(self.CannonAnim)
            end
			
            local bp = self:GetBlueprint()
			
            self.CannonAnim:PlayAnim(bp.Display.CannonOpenAnimation)
            self.CannonAnim:SetRate(bp.Display.CannonOpenRate or 1)
			
            WaitFor(self.CannonAnim)
        end,
    },
    
    ClosedState = State() {
	
        Main = function(self)
			
            if self.CannonAnim then
			
                local bp = self:GetBlueprint()
				
                self.CannonAnim:SetRate( -1 * ( bp.Display.CannonOpenRate or 1 ) )
				
                WaitFor(self.CannonAnim)
            end
        end,
    },
	
}
TypeClass = XSS0304
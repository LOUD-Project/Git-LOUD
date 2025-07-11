local CSubUnit = import('/lua/defaultunits.lua').SubUnit

local WeaponsFile = import('/lua/cybranweapons.lua')

local Torpedo   = WeaponsFile.CANNaniteTorpedoWeapon
local Bolter    = WeaponsFile.CDFElectronBolterWeapon
local Krill     = WeaponsFile.CKrilTorpedoLauncherWeapon

WeaponsFile = nil

local TorpRedirectField = import('/mods/BlackOpsUnleashed/lua/BlackOpsdefaultantiprojectile.lua').TorpRedirectField

BRS0305 = Class(CSubUnit) {
    
    Weapons = {
        DeckGun     = Class(Bolter) {},
        Torpedo     = Class(Torpedo) {
  
            FxMuzzleFlash = false,
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(56)
                
                Torpedo.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( Torpedo.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(48)
                
                    Torpedo.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(48) self:ChangeMinRadius(40) WaitTicks(44) self:ChangeMaxRadius(56) self:ChangeMinRadius(8) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },  
        },
        KrilTorp    = Class(Krill) {},
    },
	
    OnStopBeingBuilt = function(self, builder, layer)
	
        CSubUnit.OnStopBeingBuilt(self,builder,layer)
		
        if layer == 'Water' then
            ChangeState( self, self.OpenState )
        else
            ChangeState( self, self.ClosedState )
        end

        local bp = self:GetBlueprint().Defense.TorpRedirectField01
        
        local TorpRedirectField01 = TorpRedirectField { Owner = self, Radius = bp.Radius, AttachBone = bp.AttachBone, RedirectRateOfFire = bp.RedirectRateOfFire }
		
        self.Trash:Add(TorpRedirectField01)

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
	
        CSubUnit.OnLayerChange(self, new, old)
		
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
			
            local bp2 = self:GetBlueprint()
			
            self.CannonAnim:PlayAnim(bp2.Display.CannonOpenAnimation)
            self.CannonAnim:SetRate(bp2.Display.CannonOpenRate or 1)
			
            WaitFor(self.CannonAnim)
        end,
    },
    
    ClosedState = State() {
	
        Main = function(self)
			
            if self.CannonAnim then
			
                local bp2 = self:GetBlueprint()
				
                self.CannonAnim:SetRate( -1 * ( bp2.Display.CannonOpenRate or 1 ) )
				
                WaitFor(self.CannonAnim)
            end
        end,
    },
	
}

TypeClass = BRS0305
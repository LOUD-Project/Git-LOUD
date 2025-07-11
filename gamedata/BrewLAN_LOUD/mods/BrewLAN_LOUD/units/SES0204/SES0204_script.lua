local TSubUnit =  import('/lua/defaultunits.lua').SubUnit

local WeaponFile = import('/lua/terranweapons.lua')

local Torpedo       = WeaponFile.TANTorpedoAngler
local FlakCannon    = WeaponFile.TAAFlakArtilleryCannon

WeaponFile = nil

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileTorpDestroy

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add

WeaponFile = nil

SES0204 = Class(TSubUnit) {

    Weapons = {
        Torpedo = Class(Torpedo) {
  
            FxMuzzleFlash = false,
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(48)
                
                Torpedo.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( Torpedo.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(44)
                
                    Torpedo.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( Torpedo.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(56) self:ChangeMinRadius(48) WaitTicks(32) self:ChangeMaxRadius(44) self:ChangeMinRadius(8) end)
                    
                    Torpedo.RackSalvoReloadState.Main(self)

                end,
            },   
        },
        AAGun = Class(FlakCannon) {},
    },
    
	
	OnStopBeingBuilt = function(self,builder,layer)
		
		TSubUnit.OnStopBeingBuilt(self,builder,layer)

        -- create Torp Defense emitter
        local bp = __blueprints[self.BlueprintID].Defense.MissileTorpDestroy
        
        for _,v in bp.AttachBone do

            local antiMissile1 = MissileRedirect { Owner = self, Radius = bp.Radius, AttachBone = v, RedirectRateOfFire = bp.RedirectRateOfFire }

            TrashAdd( self.Trash, antiMissile1)
            
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

}

TypeClass = SES0204

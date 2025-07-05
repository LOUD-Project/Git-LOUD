local SSubUnit =  import('/lua/defaultunits.lua').SubUnit

local SeraphimWeapons = import('/lua/seraphimweapons.lua')

local Beam          = SeraphimWeapons.SDFUltraChromaticBeamGenerator02
local Torpedo       = SeraphimWeapons.SANAnaitTorpedo
local AntiTorpedo   = SeraphimWeapons.SDFAjelluAntiTorpedoDefense
local DepthCharge   = import('/lua/aeonweapons.lua').AANDepthChargeBombWeapon

SeraphimWeapons = nil

XSS0201 = Class(SSubUnit) {
    
    Weapons = {
        TurretB         = Class(Beam) {},
        TurretF         = Class(Beam) {},
        DepthCharge     = Class(DepthCharge) {
        
            OnLostTarget = function(self)
                
                self.unit:SetAccMult(1)
                
                self:ChangeMaxRadius(12)
                
                DepthCharge.OnLostTarget(self)
            
            end,
        
            RackSalvoFireReadyState = State( DepthCharge.RackSalvoFireReadyState) {
            
                Main = function(self)
                
                    self:ChangeMaxRadius(6)
                
                    DepthCharge.RackSalvoFireReadyState.Main(self)
                    
                end,
            },
        
            RackSalvoReloadState = State( DepthCharge.RackSalvoReloadState) {
            
                Main = function(self)
                
                    self.unit:SetAccMult(1.3)
                
                    self:ForkThread( function() self:ChangeMaxRadius(18) self:ChangeMinRadius(18) WaitTicks(50) self:ChangeMinRadius(0) self:ChangeMaxRadius(6) end)
                    
                    DepthCharge.RackSalvoReloadState.Main(self)

                end,
            },
        },
        Torpedo         = Class(Torpedo) { FxMuzzleFlashScale = false },
        AntiTorpedo     = Class(AntiTorpedo) {},
    },
    
    OnKilled = function(self, instigator, type, overkillRatio)
	
        local wep1 = self:GetWeaponByLabel('TurretF')
		
        if wep1 then

            local bp1 = wep1:GetBlueprint().Audio
		
            if bp1.BeamStop then
                wep1:PlaySound(bp1.BeamStop)
            end
		
            if bp1.BeamLoop and wep1.Beams[1].Beam then
                wep1.Beams[1].Beam:SetAmbientSound(nil, nil)
            end
		
            for k, v in wep1.Beams do
                v.Beam:Disable()
            end
        
        end
	
        wep1 = self:GetWeaponByLabel('TurretB')
		
        if wep1 then

            local bp1 = wep1:GetBlueprint().Audio
		
            if bp1.BeamStop then
                wep1:PlaySound(bp1.BeamStop)
            end
		
            if bp1.BeamLoop and wep1.Beams[1].Beam then
                wep1.Beams[1].Beam:SetAmbientSound(nil, nil)
            end
		
            for k, v in wep1.Beams do
                v.Beam:Disable()
            end
        
        end

        SSubUnit.OnKilled(self, instigator, type, overkillRatio)
		
    end,
    
	OnStopBeingBuilt = function(self, builder, layer)
	
		SSubUnit.OnStopBeingBuilt(self, builder, layer)
        
        self.DeathWeaponEnabled = true
		
		IssueDive({self}) -- brings it to the surface

	end,
    
    OnMotionVertEventChange = function( self,new,old)

        if new == 'Bottom' then
        
            self:EnableIntel('RadarStealth')
            self:EnableIntel('SonarStealth')
            self:DisableIntel('Radar')
            
            self:SetWeaponEnabledByLabel('DepthCharge', false)
            
            self:SetAccMult(0.75)
            self:SetSpeedMult(0.85)
            
            self:SetIntelRadius('Vision', 28)
            self:SetIntelRadius('WaterVision', 40)
        end
        
        if new == 'Top' then
            self:SetAccMult(1.0)
            self:SetSpeedMult(1.0)
            
            self:EnableIntel('Radar')
            self:DisableIntel('RadarStealth')
            self:DisableIntel('SonarStealth')

            self:SetIntelRadius('Vision', 32)
            self:SetIntelRadius('WaterVision', 28)
            
            self:SetWeaponEnabledByLabel('DepthCharge', true)

        end
        
        SSubUnit.OnMotionVertEventChange(self,new,old)

    end,
	
}

TypeClass = XSS0201
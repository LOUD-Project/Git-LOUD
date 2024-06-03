local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local TDFHeavyPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFHeavyPlasmaCannonWeapon
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

local utilities = import('/lua/Utilities.lua')
local Entity = import('/lua/sim/Entity.lua').Entity

local EffectUtils = import('/lua/effectutilities.lua')
local Effects = import('/lua/effecttemplates.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

WEL0304 = Class(TLandUnit) {

    Weapons = {
        
        AssaultCannon = Class(TDFGaussCannonWeapon) {},
        
        MiniGun = Class(TDFHeavyPlasmaCannonWeapon) {
        
            PlayFxWeaponPackSequence = function(self)
            
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Machine_Gun_Muzzle01', self.unit.Army, Effects.WeaponSteam01 )
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,

            FxChassisMuzzleFlash = {'/effects/emitters/phalanx_shells_01_emit.bp',},
            FxMuzzleFlash = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash,

            PlayFxRackSalvoChargeSequence = function(self)
            
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'spinner', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                self.SpinManip:SetTargetSpeed(500)

                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
           
            PlayFxRackSalvoReloadSequence = function(self)
            
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(200)
                end
                
                self.ExhaustEffects = EffectUtils.CreateBoneEffects( self.unit, 'Machine_Gun_Muzzle01', self.unit.Army, Effects.WeaponSteam01 )
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end, 
        },

    },

    OnStopBeingBuilt = function(self,builder,layer)
    
        TLandUnit.OnStopBeingBuilt(self,builder,layer)

        local layer = self:GetCurrentLayer()
        
        if(layer == 'Land') then
            self:CreateUnitAmbientEffect(layer)
        elseif (layer == 'Seabed') then
            self:CreateUnitAmbientEffect(layer)
        end
        
        self.WeaponsEnabled = true
    end,

	OnLayerChange = function(self, new, old)
    
		TLandUnit.OnLayerChange(self, new, old)
        
		if self.WeaponsEnabled then
			if( new == 'Land' ) then
			    self:CreateUnitAmbientEffect(new)
			elseif ( new == 'Seabed' ) then
			    self:CreateUnitAmbientEffect(new)
			end
		end
	end,
    
    AmbientExhaustBones = {'Exhaust01','Exhaust02'},	
    
    AmbientLandExhaustEffects = {'/effects/emitters/dirty_exhaust_smoke_02_emit.bp'},
	
    AmbientSeabedExhaustEffects = {'/effects/emitters/underwater_vent_bubbles_02_emit.bp'},
	
	CreateUnitAmbientEffect = function(self, layer)
    
	    if( self.AmbientEffectThread != nil ) then
	       self.AmbientEffectThread:Destroy()
        end
        
        if self.AmbientExhaustEffectsBag then
            EffectUtils.CleanupEffectBag(self,'AmbientExhaustEffectsBag')
        end        
        
        self.AmbientEffectThread = nil
        self.AmbientExhaustEffectsBag = {} 
        
	    if layer == 'Land' then
        
	        self.AmbientEffectThread = self:ForkThread(self.UnitLandAmbientEffectThread)
            
	    elseif layer == 'Seabed' then
        
	        local army = self.Army
            
			for kE, vE in self.AmbientSeabedExhaustEffects do
				for kB, vB in self.AmbientExhaustBones do
					table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ):ScaleEmitter(1) )
				end
			end	        
	    end          
	end, 
	
	UnitLandAmbientEffectThread = function(self)
    
		while not self.Dead do
        
            local army = self.Army			
			
			for kE, vE in self.AmbientLandExhaustEffects do
				for kB, vB in self.AmbientExhaustBones do
					table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ):ScaleEmitter(0.5) )
				end
			end
			
			WaitSeconds(4)
            
			EffectUtils.CleanupEffectBag(self,'AmbientExhaustEffectsBag')

			WaitSeconds(utilities.GetRandomFloat(1,7))
		end		
	end,

    CreateDamageEffects = function(self, bone, army )
    
        for k, v in Effects.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end
        
    end,
}

TypeClass = WEL0304
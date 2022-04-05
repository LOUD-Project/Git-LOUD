local TLandUnit = import('/lua/defaultunits.lua').MobileUnit

local RailGunWeapon = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').RailGunWeapon01

local TIFCruiseMissileUnpackingLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileUnpackingLauncher

local JuggLaserweapon = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').JuggLaserweapon

local JuggPlasmaGatlingCannonWeapon = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').JuggPlasmaGatlingCannonWeapon

local GetRandomFloat = import('/lua/Utilities.lua').GetRandomFloat

local CreateBoneEffects = import('/lua/effectutilities.lua').CreateBoneEffects
local CleanupEffectBag = import('/lua/effectutilities.lua').CleanupEffectBag

local Effects = import('/lua/effecttemplates.lua')
local WeaponSteam01 = import('/lua/effecttemplates.lua').WeaponSteam01

local CreateRotator = CreateRotator
local CreateAttachedEmitter = CreateAttachedEmitter

local LOUDINSERT = table.insert

BEL0307 = Class(TLandUnit) {
	
    Weapons = {
	
        MainTurret = Class(RailGunWeapon) {},

        GattlerTurret = Class(JuggPlasmaGatlingCannonWeapon) {
		
            PlayFxWeaponPackSequence = function(self)
			
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
				
				if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
				
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Gat_Muzzle_01', self.unit:GetArmy(), WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'Gat_Muzzle_02', self.unit:GetArmy(), WeaponSteam01 )
				
                JuggPlasmaGatlingCannonWeapon.PlayFxWeaponPackSequence(self)
				
            end,

        
            PlayFxRackSalvoChargeSequence = function(self)
			
                if not self.SpinManip then 
                    self.SpinManip = CreateRotator(self.unit, 'Left_Gat_Rotator', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
				
				if not self.SpinManip2 then 
                    self.SpinManip2 = CreateRotator(self.unit, 'Right_Gat_Rotator', 'z', nil, -270, 180, -60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-500)
                end
				
                JuggPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,
            
            
            PlayFxRackSalvoReloadSequence = function(self)
			
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(200)
                end
				
				if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(-200)
                end
				
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Gat_Muzzle_01', self.unit:GetArmy(), WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'Gat_Muzzle_02', self.unit:GetArmy(), WeaponSteam01 )
				
                JuggPlasmaGatlingCannonWeapon.PlayFxRackSalvoChargeSequence(self)
				
            end,    
        },
		
        Laser = Class(JuggLaserweapon) {},
		
        RocketRack = Class(TIFCruiseMissileUnpackingLauncher) {},		
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
    
    AmbientExhaustBones = { 'Exhaust_1','Exhaust_2','Exhaust_3','Exhaust_4' },	
    AmbientLandExhaustEffects = {'/effects/emitters/dirty_exhaust_smoke_02_emit.bp','/effects/emitters/dirty_exhaust_sparks_02_emit.bp' },
	AmbientSeabedExhaustEffects = {'/effects/emitters/underwater_vent_bubbles_02_emit.bp' },	
	
	CreateUnitAmbientEffect = function(self, layer)
	
	    if( self.AmbientEffectThread != nil ) then
	       self.AmbientEffectThread:Destroy()
        end	 
		
        if self.AmbientExhaustEffectsBag then
            CleanupEffectBag(self,'AmbientExhaustEffectsBag')
        end        
        
        self.AmbientEffectThread = nil
        self.AmbientExhaustEffectsBag = {} 
        
	    if layer == 'Land' then
	
	        self.AmbientEffectThread = self:ForkThread(self.UnitLandAmbientEffectThread)
			
	    elseif layer == 'Seabed' then
		
	        local army = self.Army
			local CreateAttachedEmitter = CreateAttachedEmitter
			
			for kE, vE in self.AmbientSeabedExhaustEffects do
			
				for kB, vB in self.AmbientExhaustBones do
					LOUDINSERT( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ):ScaleEmitter(1) )
				end
				
			end	
			
	    end          
	end, 
	
	UnitLandAmbientEffectThread = function(self)
	
        local army = self.Army	
		local CreateAttachedEmitter = CreateAttachedEmitter
	
		while not self.Dead do
		
			for kE, vE in self.AmbientLandExhaustEffects do
			
				for kB, vB in self.AmbientExhaustBones do
				
					LOUDINSERT( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ):ScaleEmitter(0.5) )
					
				end
			end
			
			WaitSeconds(2)
			
			CleanupEffectBag(self,'AmbientExhaustEffectsBag')
			
			WaitSeconds(GetRandomFloat(1,7))
			
		end
		
	end,

    CreateDamageEffects = function(self, bone, army )
	
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        for k, v in Effects.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end
    end,
    
    
}

TypeClass = BEL0307
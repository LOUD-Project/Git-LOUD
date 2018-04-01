local TLandUnit = import('/lua/terranunits.lua').TLandUnit
local RailGunWeapon01 = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').RailGunWeapon01
local TIFCruiseMissileUnpackingLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileUnpackingLauncher
local TDFPlasmaCannonWeapon = import('/lua/terranweapons.lua').TDFPlasmaCannonWeapon
local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')
local GetRandomFloat = import('/lua/Utilities.lua').GetRandomFloat

local CreateBoneEffects = import('/lua/effectutilities.lua').CreateBoneEffects
local CleanupEffectBag = import('/lua/effectutilities.lua').CleanupEffectBag

local Effects = import('/lua/effecttemplates.lua')
local WeaponSteam01 = import('/lua/effecttemplates.lua').WeaponSteam01

local LOUDROT = CreateRotator

XEL0307 = Class(TLandUnit) {

	ShieldEffects = {
        '/effects/emitters/terran_shield_generator_t2_01_emit.bp',
        '/effects/emitters/terran_shield_generator_t2_02_emit.bp',
    },
    Weapons = {
	
        MainTurret = Class(RailGunWeapon01) {},
		
        Turret = Class(TDFPlasmaCannonWeapon) {},
		
        RocketRack = Class(TIFCruiseMissileUnpackingLauncher) {},
		
        FlameGun = Class(TDFMachineGunWeapon) {
		
			PlayFxMuzzleSequence = function(self, muzzle)
				TDFMachineGunWeapon.PlayFxMuzzleSequence(self, muzzle)
				self.unit.lastFired = self:GetBlueprint().TurretBoneMuzzle
			end,
		},
		
        LeftGatlingCannon = Class(TDFPlasmaCannonWeapon) {
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Gat_Spinner01_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Left_Gat_Spinner02_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = LOUDROT(self.unit, 'Left_Gat_Spinner01', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if not self.SpinManip2 then 
                    self.SpinManip2 = LOUDROT(self.unit, 'Left_Gat_Spinner02', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(500)
                end
                TDFPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)
            end,            
			
        },
		
        RightGatlingCannon = Class(TDFPlasmaCannonWeapon) {
		
            PlayFxWeaponPackSequence = function(self)
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(0)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(0)
                end
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Gat_Spinner01_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                self.ExhaustEffects = CreateBoneEffects( self.unit, 'Right_Gat_Spinner02_Muzzle', self.unit:GetArmy(), WeaponSteam01 )
                TDFPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)
            end,
        
            PlayFxWeaponUnpackSequence = function(self)
                if not self.SpinManip then 
                    self.SpinManip = LOUDROT(self.unit, 'Right_Gat_Spinner01', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip)
                end
                if not self.SpinManip2 then 
                    self.SpinManip2 = LOUDROT(self.unit, 'Right_Gat_Spinner02', 'z', nil, 270, 180, 60)
                    self.unit.Trash:Add(self.SpinManip2)
                end
                if self.SpinManip then
                    self.SpinManip:SetTargetSpeed(500)
                end
                if self.SpinManip2 then
                    self.SpinManip2:SetTargetSpeed(500)
                end
                TDFPlasmaCannonWeapon.PlayFxWeaponUnpackSequence(self)
            end,            
        },
		
    },
    
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        TLandUnit.OnStopBeingBuilt(self,builder,layer)

        local layer = self:GetCurrentLayer()
        
        #-- If created with F2 on land, then play the transform anim.
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
    
    AmbientExhaustBones = {
		'Smoke_01',
		'Smoke_02',
    },	
    
    AmbientLandExhaustEffects = {
		'/effects/emitters/dirty_exhaust_smoke_02_emit.bp',
		'/effects/emitters/dirty_exhaust_sparks_02_emit.bp',			
	},
	
    AmbientSeabedExhaustEffects = {
		'/effects/emitters/underwater_vent_bubbles_02_emit.bp',			
	},	
	
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
            local army = self:GetArmy()
            
			for _, vE in self.AmbientSeabedExhaustEffects do
				for _, vB in self.AmbientExhaustBones do
					table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ):ScaleEmitter(1) )
				end
			end	        
	    end          
	end, 
	
	UnitLandAmbientEffectThread = function(self)
        local army = self:GetArmy()			
        local exeff = self.AmbientLandExhaustEffects
        local ambones = self.AmbientExhaustBones
        local LOUDINSERT = table.insert
		local CreateAttachedEmitter = CreateAttachedEmitter
        
		while not self:IsDead() do
			for _, vE in exeff do
				for _, vB in ambones do
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
		
        for _, v in EffectTemplate.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end
    end,

}

TypeClass = XEL0307
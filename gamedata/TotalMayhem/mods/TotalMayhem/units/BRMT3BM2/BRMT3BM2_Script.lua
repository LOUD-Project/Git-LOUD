local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local CWeapons = import('/lua/cybranweapons.lua')
local WeaponsFile = import('/lua/terranweapons.lua')

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local TIFCommanderDeathWeapon = WeaponsFile.TIFCommanderDeathWeapon
local CDFParticleCannonWeapon = CWeapons.CDFParticleCannonWeapon

local EffectTemplate = import('/lua/EffectTemplates.lua')

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect

local CreateAttachedEmitter = CreateAttachedEmitter
local ForkThread = ForkThread
local WaitSeconds = WaitSeconds

BRMT3BM2 = Class(CWalkingLandUnit) {

    OnStopBeingBuilt = function(self,builder,layer)
	
        CWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        local bp = self:GetBlueprint().Defense.AntiMissile
		
        local antiMissile = MissileRedirect {
            Owner = self,
            Radius = bp.Radius,
            AttachBone = bp.AttachBone,
            RedirectRateOfFire = bp.RedirectRateOfFire
        }
		
        self.Trash:Add(antiMissile)
        self.UnitComplete = true
    end,

    Weapons = {
        Rockets = Class(TDFGaussCannonWeapon) {},
		
        robottalk = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0},
		
        maingun1 = Class(TDFGaussCannonWeapon) {
		
            FxMuzzleFlashScale = 0.3,
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
                '/effects/emitters/cybran_artillery_muzzle_smoke_01_emit.bp',                                
            }, 
			
	        FxVentEffect = EffectTemplate.CDisruptorVentEffect,
	        FxVentEffect2 = EffectTemplate.WeaponSteam01,			
	        FxVentEffect3 = EffectTemplate.CDisruptorGroundEffect,
			
	        FxMuzzleEffect = EffectTemplate.CElectronBolterMuzzleFlash01,
			
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()

	            for k, v in self.FxVentEffect3 do
                    CreateAttachedEmitter(self.unit, 'BRMT3BM2', army, v):ScaleEmitter(0.4)
                end
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'rightarm_muzzle', army, v):ScaleEmitter(1.5)
                    CreateAttachedEmitter(self.unit, 'rightarm_muzzle01', army, v):ScaleEmitter(1.5)
                end
  	            for k, v in self.FxVentEffect do
                    CreateAttachedEmitter(self.unit, 'rightarm_vent01', army, v):ScaleEmitter(0.3)
                    CreateAttachedEmitter(self.unit, 'rightarm_vent02', army, v):ScaleEmitter(0.3)
                    CreateAttachedEmitter(self.unit, 'rightarm_vent04', army, v):ScaleEmitter(0.3)
                    CreateAttachedEmitter(self.unit, 'rightarm_vent05', army, v):ScaleEmitter(0.3)
                end
  	            for k, v in self.FxVentEffect2 do
                    CreateAttachedEmitter(self.unit, 'rightarm_muzzle', army, v):ScaleEmitter(0.8)
                    CreateAttachedEmitter(self.unit, 'rightarm_muzzle01', army, v):ScaleEmitter(0.8)
                end
            end,                   
        },
		
--        gatling1 = Class(TDFGaussCannonWeapon) {
        gatling1 = Class(CDFParticleCannonWeapon) {		
            FxMuzzleFlashScale = 0.1,
--[[			
            FxMuzzleFlash = { 
            	'/effects/emitters/proton_artillery_muzzle_01_emit.bp',
            	'/effects/emitters/proton_artillery_muzzle_03_emit.bp',
            }, 

	        FxMuzzleEffect = EffectTemplate.CElectronBolterMuzzleFlash01,
--]]
--[[
	        PlayFxMuzzleSequence = function(self, muzzle)
		        local army = self.unit:GetArmy()
		        
  	            for k, v in self.FxMuzzleEffect do
                    CreateAttachedEmitter(self.unit, 'gunstikkflamme', army, v):ScaleEmitter(0.4)
                end
            end,                   
--]]
        },

    },
	
    AmbientExhaustBones = {
		'Exhaust01',
		'Exhaust02',
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
            EffectUtil.CleanupEffectBag(self,'AmbientExhaustEffectsBag')
        end        
        
        self.AmbientEffectThread = nil
        self.AmbientExhaustEffectsBag = {} 
		
	    if layer == 'Land' then
	        self.AmbientEffectThread = self:ForkThread(self.UnitLandAmbientEffectThread)
			
	    elseif layer == 'Seabed' then
	        local army = self:GetArmy()
			for kE, vE in self.AmbientSeabedExhaustEffects do
				for kB, vB in self.AmbientExhaustBones do
					table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
				end
			end	        
	    end          
	end, 
	
	UnitLandAmbientEffectThread = function(self)
		while not self:IsDead() do
            local army = self:GetArmy()			
			
			for kE, vE in self.AmbientLandExhaustEffects do
				for kB, vB in self.AmbientExhaustBones do
					table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
				end
			end
			
			WaitSeconds(2)
			EffectUtil.CleanupEffectBag(self,'AmbientExhaustEffectsBag')
	
			WaitSeconds(utilities.GetRandomFloat(1,7))
		end		
	end,
}

TypeClass = BRMT3BM2
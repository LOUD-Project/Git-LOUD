local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CDFRocketIridiumWeapon        = import('/lua/cybranweapons.lua').CDFRocketIridiumWeapon
local CAAMissileNaniteWeapon        = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local CDFHeavyElectronBolterWeapon  = import('/lua/cybranweapons.lua').CDFHeavyElectronBolterWeapon

local util = import('/lua/utilities.lua')

local CleanupEffectBag = import('/lua/effectutilities.lua').CleanupEffectBag

URA0401 = Class(CAirUnit) {

    Weapons = {
        Missile     = Class(CDFRocketIridiumWeapon) {},
        HeavyBolter = Class(CDFHeavyElectronBolterWeapon){},
        AAMissile   = Class(CAAMissileNaniteWeapon) {},
    },
    
    MovementAmbientExhaustBones = {
		'Exhaust_Left01',
		'Exhaust_Left02',
		'Exhaust_Left03',
		'Exhaust_Right01',
		'Exhaust_Right02',
		'Exhaust_Right03',
    },

    DestructionPartsChassisToss = {'URA0401',},
    DestroyNoFallRandomChance = 7.5,

    OnStopBeingBuilt = function(self,builder,layer)
	
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
		
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip) 

    end,
    
    OnMotionHorzEventChange = function(self, new, old )
	
		CAirUnit.OnMotionHorzEventChange(self, new, old)
	
		if self.ThrustExhaustTT1 == nil then
		
			if self.MovementAmbientExhaustEffectsBag then
				CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			else
				self.MovementAmbientExhaustEffectsBag = {}
			end
			
			self.ThrustExhaustTT1 = self:ForkThread(self.MovementAmbientExhaustThread)
		end
		
        if new == 'Stopped' and self.ThrustExhaustTT1 != nil then
		
			KillThread(self.ThrustExhaustTT1)
			
			CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			
			self.ThrustExhaustTT1 = nil
        end		 
    end,
    
    MovementAmbientExhaustThread = function(self)
	
		while not self.Dead do
		
			local ExhaustEffects = {
				'/effects/emitters/dirty_exhaust_smoke_01_emit.bp',
				'/effects/emitters/dirty_exhaust_sparks_01_emit.bp',			
			}
			
			local ExhaustBeam = '/effects/emitters/missile_exhaust_fire_beam_03_emit.bp'
            
			local army = self:GetArmy()	
			local CreateAttachedEmitter = CreateAttachedEmitter
			local CreateBeamEmitterOnEntity = CreateBeamEmitterOnEntity
			local LOUDINSERT = table.insert
			
			for kE, vE in ExhaustEffects do
				for kB, vB in self.MovementAmbientExhaustBones do
					LOUDINSERT( self.MovementAmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
					LOUDINSERT( self.MovementAmbientExhaustEffectsBag, CreateBeamEmitterOnEntity( self, vB, army, ExhaustBeam ))
				end
			end
			
			WaitSeconds(2)
			CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')

			WaitSeconds(util.GetRandomFloat(1,7))
		end	
    end,

    OnMotionVertEventChange = function(self, new, old)
		
		CAirUnit.OnMotionVertEventChange(self, new, old)
		
		if ((new == 'Top' or new == 'Up') and old == 'Down') then
		
			self.AnimManip:SetRate(-1)
			
		elseif (new == 'Down') then
		
			self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationLand, false):SetRate(1.5)
			
		elseif (new == 'Up') then
		
			self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationTakeOff, false):SetRate(1)
			
		end

    end,
}

TypeClass = URA0401
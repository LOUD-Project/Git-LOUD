local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CDFRocketIridiumWeapon = import('/lua/cybranweapons.lua').CDFRocketIridiumWeapon
local CAAMissileNaniteWeapon = import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon
local CDFHeavyElectronBolterWeapon = import('/lua/cybranweapons.lua').CDFHeavyElectronBolterWeapon
local CDFLaserDisintegratorWeapon = import('/lua/cybranweapons.lua').CDFLaserDisintegratorWeapon01

local util = import('/lua/utilities.lua')
local fxutil = import('/lua/effectutilities.lua')

local CDFHeavyMicrowaveLaserGeneratorCom = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGeneratorCom

WRA0401 = Class(CAirUnit) {
    Weapons = {
        Missile = Class(CDFRocketIridiumWeapon) {},

		Laser = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},

        Disintegrator = Class(CDFLaserDisintegratorWeapon){},

        AA = Class(CAAMissileNaniteWeapon) {},
    },
    
    MovementAmbientExhaustBones = {
		'Exhaust01',
		'Exhaust02',
		'Exhaust03',
		'Exhaust04',
		'Exhaust05',
		'Exhaust06',
    },

    DestructionPartsChassisToss = {'WRA0401',},
    DestroyNoFallRandomChance = 1.1,

    OnMotionHorzEventChange = function(self, new, old )
    
		CAirUnit.OnMotionHorzEventChange(self, new, old)
	
		if self.ThrustExhaustTT1 == nil then 
			if self.MovementAmbientExhaustEffectsBag then
				fxutil.CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			else
				self.MovementAmbientExhaustEffectsBag = {}
			end
			self.ThrustExhaustTT1 = self:ForkThread(self.MovementAmbientExhaustThread)
		end
		
        if new == 'Stopped' and self.ThrustExhaustTT1 != nil then
			KillThread(self.ThrustExhaustTT1)
			fxutil.CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			self.ThrustExhaustTT1 = nil
        end		 
    end,
    
    MovementAmbientExhaustThread = function(self)
		while not self:IsDead() do
			local ExhaustEffects = {
				'/effects/emitters/dirty_exhaust_smoke_01_emit.bp',
				'/effects/emitters/dirty_exhaust_sparks_01_emit.bp',			
			}
			local ExhaustBeam = '/effects/emitters/missile_exhaust_fire_beam_03_emit.bp'
			local army = self:GetArmy()			
			
			for kE, vE in ExhaustEffects do
				for kB, vB in self.MovementAmbientExhaustBones do
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ))
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateBeamEmitterOnEntity( self, vB, army, ExhaustBeam ))
				end
			end
			
			WaitSeconds(2)
			fxutil.CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
							
			WaitSeconds(util.GetRandomFloat(1,7))
		end	
    end,

}

TypeClass = WRA0401
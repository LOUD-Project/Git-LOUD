local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local CDFRocketIridiumWeapon                = import('/lua/cybranweapons.lua').CDFRocketIridiumWeapon
local CDFLaserDisintegratorWeapon           = import('/lua/cybranweapons.lua').CDFLaserDisintegratorWeapon01
local CDFHeavyMicrowaveLaserGeneratorCom    = import('/lua/cybranweapons.lua').CDFHeavyMicrowaveLaserGeneratorCom
local CAAMissileNaniteWeapon                = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

local util      = import('/lua/utilities.lua')
local fxutil    = import('/lua/effectutilities.lua')



WRA0401 = Class(CAirUnit) {

    Weapons = {
        Missile         = Class(CDFRocketIridiumWeapon) {},
        Disintegrator   = Class(CDFLaserDisintegratorWeapon){},
		Laser           = Class(CDFHeavyMicrowaveLaserGeneratorCom) {},
        AA              = Class(CAAMissileNaniteWeapon) {},
    },
    
    MovementAmbientExhaustBones = {'Exhaust01','Exhaust02','Exhaust03','Exhaust04','Exhaust05','Exhaust06'},

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

        local army = self.Sync.army
        local ExhaustEffects = {'/effects/emitters/dirty_exhaust_smoke_01_emit.bp','/effects/emitters/dirty_exhaust_sparks_01_emit.bp'}
		local ExhaustBeam = '/effects/emitters/missile_exhaust_fire_beam_03_emit.bp'
    
		while not self.Dead do

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
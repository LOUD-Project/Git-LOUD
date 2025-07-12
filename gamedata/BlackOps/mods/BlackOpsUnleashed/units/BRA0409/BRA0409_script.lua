local CAirUnit = import('/lua/defaultunits.lua').AirUnit

local explosion = import('/lua/defaultexplosions.lua')

local Laser = import('/lua/cybranweapons.lua').CDFParticleCannonWeapon
local Missile = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local TurboLaser = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').RedHeavyTurboLaserWeapon

local util = import('/lua/utilities.lua')
local fxutil = import('/lua/effectutilities.lua')

local ForkThread = ForkThread
local KillThread = KillThread

BRA0409 = Class(CAirUnit) {

    DestroyNoFallRandomChance = 1.1,
	
    Weapons = {
        
        AA = Class(Laser) {},
		
        RocketPod = Class(TurboLaser) {},
		
        MainGun = Class(Missile) {},
    },

    AirDestructionEffectBones = { 'Engine_01', 'Engine_02', 'Engine_03', 'Engine_04', 'Engine_05', 'Main_Gun_Turret', 'L_Barrel_01', 'R_Barrel_01','L_Back_Barrel_01', 'R_Back_Turret_01', 'Main_Gun_Muzzle','R_Turret_01', 'R_U_Muzzle_01',     'R_Pivot01', 'L_pivot_01', 'L_Back_Turret_01','R_B_AA_Muzzle_01','R_Back_Barrel_01'},

    BeamExhaustIdle = '/effects/emitters/missile_exhaust_fire_beam_05_emit.bp',
    BeamExhaustCruise = '/effects/emitters/missile_exhaust_fire_beam_04_emit.bp',
   
    MovementAmbientExhaustBones = {
		'Engine_01',
		'Engine_02',
		'Engine_03',
    },
    MovementAmbientExhaustBones2 = {
		'Engine_04',
		'Engine_05',
    },


    -- When one of our attached units gets killed, detach it
    OnAttachedKilled = function(self, attached)
        attached:DetachFrom()
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        CAirUnit.OnKilled(self, instigator, type, overkillRatio)
        -- TransportDetachAllUnits takes 1 bool parameter. If true, randomly destroys some of the transported
        -- units, otherwise successfully detaches all.
        self:TransportDetachAllUnits(false)
    end,
    
    OnTransportAttach = function(self, attachBone, unit)
        CAirUnit.OnTransportAttach(self, attachBone, unit)
        unit:SetCanTakeDamage(false) # making transported unit invulnerable inside transport
    end,

    OnTransportDetach = function(self, attachBone, unit)
        unit:SetCanTakeDamage(true) # Units dropped by the transport shouldnt be vulnerable
        CAirUnit.OnTransportDetach(self, attachBone, unit)
    end,


    # Override air destruction effects so we can do something custom here
    CreateUnitAirDestructionEffects = function( self, scale )
        self:ForkThread(self.AirDestructionEffectsThread, self )
    end,

    AirDestructionEffectsThread = function( self )
        local numExplosions = math.floor( table.getn( self.AirDestructionEffectBones ) * 3 )
        for i = 0, numExplosions do
            explosion.CreateDefaultHitExplosionAtBone( self, self.AirDestructionEffectBones[util.GetRandomInt( 3, numExplosions )], 4 )
            WaitSeconds( util.GetRandomFloat( 0.5, 1.9 ))
        end
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
        CAirUnit.OnStopBeingBuilt(self,builder,layer)
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
        self:SetMaintenanceConsumptionInactive()
        --self:SetScriptBit('RULEUTC_IntelToggle', true)		#-- used to have cloaking but removed it
		self:SetScriptBit('RULEUTC_StealthToggle', false)		#-- turn ON stealth field
    end,

    
    OnMotionHorzEventChange = function(self, new, old)
        --LOG( 'OnMotionHorzEventChange, new = ', new, ', old = ', old )
        CAirUnit.OnMotionHorzEventChange(self, new, old)
        if self.ThrustExhaustTT1 == nil then 
			if self.MovementAmbientExhaustEffectsBag then
				fxutil.CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			else
				self.MovementAmbientExhaustEffectsBag = {}
			end
			self.ThrustExhaustTT1 = self:ForkThread(self.MovementAmbientExhaustThread)
		end
        
        if (new == 'TopSpeed') then
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(2)       
       elseif (new == 'Stopping') then
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationClose, false):SetRate(2)
       elseif new == 'Stopped' and self.ThrustExhaustTT1 != nil then
			KillThread(self.ThrustExhaustTT1)
			fxutil.CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')
			self.ThrustExhaustTT1 = nil
        end		 
    end,
    
    MovementAmbientExhaustThread = function(self)
		while not self.Dead do
		
			local ExhaustEffects = {
				'/effects/emitters/dirty_exhaust_smoke_01_emit.bp',
				'/effects/emitters/dirty_exhaust_sparks_01_emit.bp',			
			}
			
			local ExhaustBeamLarge = '/mods/BlackOpsUnleashed/effects/emitters/missile_exhaust_fire_beam_10_emit.bp'
			local ExhaustBeamSmall = '/effects/emitters/missile_exhaust_fire_beam_03_emit.bp'
			
			local army = self.Army	

			local CreateAttachedEmitter = CreateAttachedEmitter
			local CreateBeamEmitterOnEntity = CreateBeamEmitterOnEntity
			
			for kE, vE in ExhaustEffects do
				for kB, vB in self.MovementAmbientExhaustBones do
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ):ScaleEmitter(2))
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateBeamEmitterOnEntity( self, vB, army, ExhaustBeamLarge ))
				end
				for kB, vB in self.MovementAmbientExhaustBones2 do
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, army, vE ):ScaleEmitter(1))
					table.insert( self.MovementAmbientExhaustEffectsBag, CreateBeamEmitterOnEntity( self, vB, army, ExhaustBeamSmall ))
				end
			end
			
			WaitTicks(50)
			fxutil.CleanupEffectBag(self,'MovementAmbientExhaustEffectsBag')

		end	
    end,
}

TypeClass = BRA0409


local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone
local EffectTemplate = import('/lua/EffectTemplates.lua')
local BlackOpsEffectTemplate = import('/mods/BlackOpsACUs/lua/EXBlackOpsEffectTemplates.lua')

EEA0002 = Class(TAirUnit) {

    DestroyNoFallRandomChance = 1.1,
    
    HideBones = { 'Shell01', 'Shell02', 'Shell03', 'Shell04', },
    
    Parent = nil,

    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.Pod = podName
    end,

	OnStopBeingBuilt = function(self,builder,layer)
	
		TAirUnit.OnStopBeingBuilt(self)

	end,
	
    OnKilled = function(self, instigator, type, overkillRatio)
	
        if self.IsDying then 
            return 
        end
		
		local army = self:GetArmy()

        self.IsDying = true
		
        self.Parent:NotifyOfPodDeath(self.Pod)
		
        self.Parent = nil
		
		self:ForkThread(self.DeathEffectsThread)
		
        TAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    Open = function(self)
	
		WaitTicks(10)
	
        ChangeState( self, self.OpenState )
    end,
    
    OpenState = State() {
	
        Main = function(self)
		
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim( '/mods/BlackopsACUs/units/EEA0002/eea0002_aopen01.sca' )
			
            self.Trash:Add( self.OpenAnim )

			WaitTicks(50)
            
            for k,v in self.HideBones do
                self:HideBone( v, true )
            end
            
            self.OpenAnim:PlayAnim( '/mods/BlackopsACUs/units/EEA0002/eea0002_aopen02.sca' )
			
			LOG("*AI DEBUG Sat Launch complete")

        end,

    },

	CreateDamageEffects = function(self, bone, army )
        for k, v in BlackOpsEffectTemplate.SatDeathEffectsPackage do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(6)
        end
    end,
	
	CreateExplosionDebris = function( self, bone, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, bone, army, v )--:OffsetEmitter( 0, 5, 0 )
        end
    end,

	DeathEffectsThread = function(self)
		local army = self:GetArmy()
        # Create Initial explosion effects
        explosion.CreateFlash( self, 'XEA0002', 1.5, army )
        CreateAttachedEmitter(self,'Turret_Barrel_Muzzle', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp'):OffsetEmitter( 0, 0, 0 ) --Sparks
        CreateAttachedEmitter(self,'Turret_Barrel_Muzzle', army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.3)

        self:CreateExplosionDebris('XEA0002', army ) --Debris spread
        CreateDeathExplosion( self, 'XEA0002', 1.5) -- Simple Explosion
        self:CreateDamageEffects( 'XEA0002', army ) -- Fireball & trailing smoke
		self:CreateDamageEffects( 'L_Panel03', army )
		self:CreateDamageEffects( 'R_Panel03', army )
    end,
    
}
TypeClass = EEA0002
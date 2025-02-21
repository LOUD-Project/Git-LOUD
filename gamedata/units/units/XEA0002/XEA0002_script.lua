local TAirUnit = import('/lua/defaultunits.lua').AirUnit

local explosion             = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion  = explosion.CreateDefaultHitExplosionAtBone
local CreateFlash           = explosion.CreateFlash

explosion = nil

local EffectTemplate            = import('/lua/EffectTemplates.lua').ExplosionDebrisLrg01
local BlackOpsEffectTemplate    = import('/mods/BlackOpsACUs/lua/EXBlackOpsEffectTemplates.lua').SatDeathEffectsPackage

XEA0002 = Class(TAirUnit) {

    DestroyNoFallRandomChance = 1.1,
    
    HideBones = { 'Shell01', 'Shell02', 'Shell03', 'Shell04', },
    
    Parent = nil,

    SetParent = function(self, parent, podName)
        self.Parent = parent
    end,

	OnStopBeingBuilt = function(self,builder,layer)
	
		TAirUnit.OnStopBeingBuilt(self)

	end,
	
    OnKilled = function(self, instigator, type, overkillRatio)
	
        if self.IsDying then 
            return 
        end

        self.IsDying = true

        self.Parent = nil
		
		self:ForkThread(self.DeathEffectsThread)
		
        TAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

    Open = function(self)
	
		WaitTicks(15)
	
        ChangeState( self, self.OpenState )
    end,
    
    OpenState = State() {
	
        Main = function(self)
		
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim( '/units/XEA0002/xea0002_aopen01.sca' )
			
            self.Trash:Add( self.OpenAnim )

			WaitTicks(50)
            
            for k,v in self.HideBones do
                self:HideBone( v, true )
            end
            
            self.OpenAnim:PlayAnim( '/units/XEA0002/xea0002_aopen02.sca' )
        end,

    },

	CreateDamageEffects = function(self, bone, army )

        for k, v in BlackOpsEffectTemplate do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(6)
        end

    end,
	
	CreateExplosionDebris = function( self, bone, army )

        for k, v in EffectTemplate do
            CreateAttachedEmitter( self, bone, army, v )
        end

    end,

	DeathEffectsThread = function(self)

		local army = self:GetArmy()

        CreateFlash( self, 'XEA0002', 1.5, army )

        CreateAttachedEmitter(self,'Turret_Barrel_Muzzle', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp'):OffsetEmitter( 0, 0, 0 ) --Sparks
        CreateAttachedEmitter(self,'Turret_Barrel_Muzzle', army, '/effects/emitters/distortion_ring_01_emit.bp'):ScaleEmitter(0.3)

        self:CreateExplosionDebris('XEA0002', army )    --Debris spread

        CreateDeathExplosion( self, 'XEA0002', 1.5)     -- Simple Explosion

        self:CreateDamageEffects( 'XEA0002', army )     -- Fireball & trailing smoke
		self:CreateDamageEffects( 'L_Panel03', army )
		self:CreateDamageEffects( 'R_Panel03', army )

    end,
    
}

TypeClass = XEA0002
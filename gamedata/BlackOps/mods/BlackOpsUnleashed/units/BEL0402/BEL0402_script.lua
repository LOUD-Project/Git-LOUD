local TWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local Missile   = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local SAM       = import('/lua/terranweapons.lua').TSAMLauncher
local Death     = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon

local Gauss     = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').HawkGaussCannonWeapon
local Beam      = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').GoliathShoulderBeam
local TMD       = import('/mods/BlackOpsUnleashed/lua/BlackOpsweapons.lua').GoliathTMDGun

local utilities     = import('/lua/utilities.lua')
local RandomFloat   = utilities.GetRandomFloat

local EffectTemplate = import('/lua/EffectTemplates.lua')

local explosion = import('/lua/defaultexplosions.lua')

local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone

local ForkThread = ForkThread
local ChangeState = ChangeState
local CreateAttachedEmitter = CreateAttachedEmitter

local LOUDCOS = math.cos
local LOUDINSERT = table.insert
local LOUDSIN = math.sin

BEL0402 = Class(TWalkingLandUnit) {

	FlamerEffects = { '/mods/BlackOpsUnleashed/effects/emitters/ex_flamer_torch_01.bp' },
	
	Weapons = {
		
		MissileWeapon = Class(Missile) {},
		
		Laser = Class(Beam) {},
	
		Flamer = Class(Gauss) {},
	
		Flamer2 = Class(Gauss) {},		

		TMDTurret = Class(TMD) {},
		
		HeadWeapon = Class(SAM){},
		
		GoliathDeathNuck = Class(Death) {},
	},
	
	OnStartBeingBuilt = function(self, builder, layer)
	
		TWalkingLandUnit.OnStartBeingBuilt(self, builder, layer)
		
		if not self.AnimationManipulator then
			self.AnimationManipulator = CreateAnimator(self)
			self.Trash:Add(self.AnimationManipulator)
		end
		
		self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, false):SetRate(0)
	end,
	
	OnStopBeingBuilt = function(self,builder,layer)
	
		TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)		
		
		if self.AnimationManipulator then
		
			self:SetUnSelectable(true)
			self.AnimationManipulator:SetRate(1)
			
			self:ForkThread(function()
				WaitSeconds(self.AnimationManipulator:GetAnimationDuration()*self.AnimationManipulator:GetRate())
				self:SetUnSelectable(false)
				self.AnimationManipulator:Destroy()
			end)
		end 
		
		self.FlamerEffectsBag = {}
		
		if self.FlamerEffectsBag then
		
			for k, v in self.FlamerEffectsBag do
				v:Destroy()
			end
			
			self.FlamerEffectsBag = {}
		end

		for k, v in self.FlamerEffects do
			LOUDINSERT( self.FlamerEffectsBag, CreateAttachedEmitter( self, 'Right_Pilot_Light', self:GetArmy(), v ):ScaleEmitter(0.0625) )
			LOUDINSERT( self.FlamerEffectsBag, CreateAttachedEmitter( self, 'Left_Pilot_Light', self:GetArmy(), v ):ScaleEmitter(0.0625) )
		end
	end,

	DestructionEffectBones = {'Left_Arm_Muzzle'},
	
	CreateDamageEffects = function(self, bone, army )
        for k, v in EffectTemplate.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(3.0)
        end
    end,

	CreateExplosionDebris = function( self, bone, Army )
	
		local CreateAttachedEmitter = CreateAttachedEmitter
		
		for k, v in EffectTemplate.ExplosionEffectsSml01 do
			CreateAttachedEmitter( self, bone, Army, v ):ScaleEmitter(2.0)
		end
	end,
	
	CreateDeathExplosionDustRing = function( self )
        local blanketSides = 18
        local blanketAngle = 6.28 / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2.8

        for i = 0, (blanketSides-1) do
            local blanketX = LOUDSIN(i*blanketAngle)
            local blanketZ = LOUDCOS(i*blanketAngle)

            local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 1.5, blanketZ + 4, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end        
    end,

	CreateAmmoCookOff = function( self, Army, bones, yBoneOffset )

		local basePosition = self:GetPosition()
        
		for k, vBone in bones do
        
			local position = self:GetPosition(vBone)
			local offset = utilities.GetDifferenceVector( position, basePosition )
            
			velocity = utilities.GetDirectionVector( position, basePosition ) 
            
			velocity[1] = velocity[1] + GetRandomFloat(-0.45, 0.45)
			velocity[2] = velocity[2] + GetRandomFloat(-0.45, 0.45)
			velocity[3] = velocity[3] + GetRandomFloat( 0.0, 0.65)

			self.DamageData = {
				BallisticArc = 'RULEUBA_LowArc',
				UseGravity = true, 
				CollideFriendly = true, 
				DamageFriendly = true, 
				Damage = 500,
				DamageRadius = 3,
				DoTPulses = 15,
				DoTTime = 2.5, 
				DamageType = 'Normal',
			} 

			ammocookoff = self:CreateProjectile('/mods/BlackOpsUnleashed/projectiles/NapalmProjectile01/Napalm01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity[1], velocity[2], velocity[3])

			ammocookoff:SetVelocity(Random(2,5))  
			ammocookoff:SetLifetime(20) 
			ammocookoff:PassDamageData(self.DamageData)
			self.Trash:Add(ammocookoff)
		end
	end,
	
	CreateGroundPlumeConvectionEffects = function(self,army)
    
        for k, v in EffectTemplate.TNukeGroundConvectionEffects01 do
            CreateEmitterAtEntity(self, army, v ) 
        end
    
        local sides = 10
        local angle = 6.28 / sides
        local inner_lower_limit = 2
        local outer_lower_limit = 2
        local outer_upper_limit = 2
    
        local inner_lower_height = 1
        local inner_upper_height = 3
        local outer_lower_height = 2
        local outer_upper_height = 3

        sides = 8
        angle = 6.28 / sides
    
        for i = 0, (sides-1) do
        
            local magnitude = RandomFloat(outer_lower_limit, outer_upper_limit)
            local x = LOUDSIN(i*angle+RandomFloat(-angle/2, angle/4)) * magnitude
            local z = LOUDCOS(i*angle+RandomFloat(-angle/2, angle/4)) * magnitude
            local velocity = RandomFloat( 1, 3 ) * 3
            self:CreateProjectile('/effects/entities/UEFNukeEffect05/UEFNukeEffect05_proj.bp', x, RandomFloat(outer_lower_height, outer_upper_height), z, x, 0, z)
                :SetVelocity(x * velocity, 0, z * velocity)
        end 
    end,
	
	CreateInitialFireballSmokeRing = function(self)
        local sides = 12
        local angle = 6.28 / sides
        local velocity = 5
        local OffsetMod = 8       

        for i = 0, (sides-1) do
            local X = LOUDSIN(i*angle)
            local Z = LOUDCOS(i*angle)
            self:CreateProjectile('/effects/entities/UEFNukeShockwave01/UEFNukeShockwave01_proj.bp', X * OffsetMod , 1.5, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity):SetAcceleration(-0.5)
        end   
    end,  
    
    CreateOuterRingWaveSmokeRing = function(self)
        local sides = 32
        local angle = 6.28 / sides
        local velocity = 7
        local OffsetMod = 8
        local projectiles = {}

        for i = 0, (sides-1) do
            local X = LOUDSIN(i*angle)
            local Z = LOUDCOS(i*angle)
            local proj =  self:CreateProjectile('/effects/entities/UEFNukeShockwave02/UEFNukeShockwave02_proj.bp', X * OffsetMod , 2.5, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity)
            LOUDINSERT( projectiles, proj )
        end  
        
        WaitSeconds( 2 )

        for k, v in projectiles do
            v:SetAcceleration(-0.45)
        end         
    end,      
    
    CreateFlavorPlumes = function(self)
    
        local numProjectiles = 8
        local angle = 6.28 / numProjectiles
        local angleInitial = RandomFloat( 0, angle )
        local angleVariation = angle * 0.75
        local projectiles = {}

        local xVec = 0 
        local yVec = 0
        local zVec = 0
        local velocity = 0

        # yVec -0.2, requires 2 initial velocity to start
        # yVec 0.3, requires 3 initial velocity to start
        # yVec 1.8, requires 8.5 initial velocity to start

        # Launch projectiles at semi-random angles away from the sphere, with enough
        # initial velocity to escape sphere core
        for i = 0, (numProjectiles -1) do
            xVec = LOUDSIN(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))
            yVec = RandomFloat(0.2, 1)
            zVec = LOUDCOS(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation)) 
            velocity = 3.4 + (yVec * RandomFloat(2,5))
            LOUDINSERT(projectiles, self:CreateProjectile('/effects/entities/UEFNukeFlavorPlume01/UEFNukeFlavorPlume01_proj.bp', 0, 0, 0, xVec, yVec, zVec):SetVelocity(velocity) )
        end

        WaitSeconds( 2 )

        # Slow projectiles down to normal speed
        for k, v in projectiles do
            v:SetVelocity(2):SetBallisticAcceleration(-0.15)
        end
    end,
	
	CreateHeadConvectionSpinners = function(self)
    
        local sides = 8
        local angle = 6.28 / sides
        local HeightOffset = 0
        local velocity = 1
        local OffsetMod = 10
        local projectiles = {}        

        for i = 0, (sides-1) do
            local x = LOUDSIN(i*angle) * OffsetMod
            local z = LOUDCOS(i*angle) * OffsetMod
            local proj = self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/GoliathNukeEffect03/GoliathNukeEffect03_proj.bp', x, HeightOffset, z, x, 0, z)
                :SetVelocity(velocity)
            LOUDINSERT(projectiles, proj)
        end   
    
        WaitSeconds(1)
        
        for i = 0, (sides-1) do
            local x = LOUDSIN(i*angle)
            local z = LOUDCOS(i*angle)
            local proj = projectiles[i+1]
            
            proj:SetVelocityAlign(false)
            proj:SetOrientation(OrientFromDir(utilities.Cross( Vector(x,0,z), Vector(0,1,0))),true)
            proj:SetVelocity(0,3,0) 
            proj:SetBallisticAcceleration(-0.05)            
        end   
    end,
	
	
	DeathThread = function( self, overkillRatio , instigator)
	
		local army = self.Army
        local position = self:GetPosition()
		local numExplosions =  math.floor( table.getn( self.DestructionEffectBones ) * Random(0.4, 1.0))
        
		self:PlayUnitSound('Destroyed')
        
		# Create small explosions effects all over
		local ranBone = utilities.GetRandomInt( 1, numExplosions )
        
		CreateDeathExplosion( self, 'Torso', 6)
        CreateAttachedEmitter(self, 'Torso', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):OffsetEmitter( 0, 0, 0 )
		self:ShakeCamera(20, 2, 1, 1)
		WaitSeconds(2)
		explosion.CreateDefaultHitExplosionAtBone( self, 'Torso', 5.0 )
		WaitSeconds(0.8)
		explosion.CreateDefaultHitExplosionAtBone( self, 'Missile_Hatch_B', 5.0 )
		self:CreateDamageEffects( 'Missile_Hatch_B', army )
		self:ShakeCamera(20, 2, 1, 1.5)
		WaitSeconds(0.8)
		CreateDeathExplosion( self, 'Left_Arm_Extra', 1.0 )
		WaitSeconds(0.4)
		CreateDeathExplosion( self, 'Left_Arm_Muzzle', 1.0 )

		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Left_Arm_Pitch', 1.0 )
		self:CreateDamageEffects( 'Left_Arm_Pitch', army )

		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Left_Leg_B', 1.0 )
		self:CreateDamageEffects( 'Left_Leg_B', army )
		WaitSeconds(0.5)
		CreateDeathExplosion( self, 'Right_Arm_Extra', 1.0 )

		CreateDeathExplosion( self, 'Left_Arm_Yaw', 1.0 )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Right_Leg_B', 1.0 )
		WaitSeconds(0.8)
		CreateDeathExplosion( self, 'Pelvis', 1.0 )
		CreateDeathExplosion( self, 'Beam_Barrel', 1.0 )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Head', 1.0 )

		WaitSeconds(0.4)
		CreateDeathExplosion( self, 'AttachSpecial01', 1.0 )
		self:CreateDamageEffects( 'AttachSpecial01', army )
		WaitSeconds(0.3)
		CreateDeathExplosion( self, 'TMD_Turret', 1.0 )
		self:CreateDamageEffects( 'TMD_Turret', army )
		WaitSeconds(0.3)
		CreateDeathExplosion( self, 'Left_Leg_C', 1.0 )
		self:CreateDamageEffects( 'Left_Leg_C', army )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'L_FootFall', 1.0 )
		CreateDeathExplosion( self, 'Left_Foot', 1.0 )

		WaitSeconds(0.1)
		CreateDeathExplosion( self, 'Right_Foot', 1.0 )
		WaitSeconds(0.6)
		CreateDeathExplosion( self, 'Beam_Turret', 2.0 )
		self:CreateDamageEffects( 'Beam_Turret', army )
		self:CreateDamageEffects( 'Right_Arm_Extra', army )

		WaitSeconds(0.6)
		CreateDeathExplosion( self, 'Torso', 1.0 )
		WaitSeconds(0.2)
		CreateDeathExplosion( self, 'Right_Leg_B', 1.0 )
		self:CreateDamageEffects( 'Right_Leg_B', army )
		WaitSeconds(0.4)
		CreateDeathExplosion( self, 'Right_Arm_Pitch', 1.0 )

		self:CreateDamageEffects( 'Right_Arm_Pitch', army )
		WaitSeconds(1.2)
		
		local x, y, z = unpack(self:GetPosition())
        z = z + 3
        -- Knockdown force rings
        
		
        -- Create initial fireball dome effect
		--CreateLightParticle(self, -1, self:GetArmy(), 50, 100, 'beam_white_01', 'ramp_blue_16')
		CreateLightParticle(self, -1, army, 35, 4, 'glow_02', 'ramp_red_02')
        
        WaitSeconds(0.2)
        
        CreateLightParticle(self, -1, army, 80, 20, 'glow_03', 'ramp_fire_06')
        
		self:PlayUnitSound('NukeExplosion')
        
        local FireballDomeYOffset = -7
        
        self:CreateProjectile('/mods/BlackOpsUnleashed/effects/entities/GoliathNukeEffect01/GoliathNukeEffect01_proj.bp',0,FireballDomeYOffset,0,0,0,1)
        
        local PlumeEffectYOffset = 1
        self:CreateProjectile('/effects/entities/UEFNukeEffect02/UEFNukeEffect02_proj.bp',0,PlumeEffectYOffset,0,0,0,1) 
        
		DamageRing(self, position, 0.1, 18, 1, 'Force', true)
        
        WaitSeconds(0.6)
        
        DamageRing(self, position, 0.1, 18, 1, 'Force', true)
        
		local bp = __blueprints[self.BlueprintID]
        
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'DeathWeapon') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end
		
		for k, v in EffectTemplate.TNukeRings01 do
			CreateEmitterAtEntity(self, army, v )
        end
        
        self:CreateInitialFireballSmokeRing()
        self:ForkThread(self.CreateOuterRingWaveSmokeRing)
        self:ForkThread(self.CreateHeadConvectionSpinners)
        self:ForkThread(self.CreateFlavorPlumes)
		
		CreateLightParticle(self, -1, army, 200, 150, 'glow_03', 'ramp_nuke_04')

		WaitSeconds(1.2)

		self:CreateGroundPlumeConvectionEffects(army)
		
		local army = self.Army
        
        CreateDecal(self:GetPosition(), RandomFloat(0, 6.28), 'nuke_scorch_003_albedo', '', 'Albedo', 40, 40, 500, 0, army)

        self:CreateWreckage(0.1)
        self:Destroy()
		
	end,
	
	
}

TypeClass = BEL0402
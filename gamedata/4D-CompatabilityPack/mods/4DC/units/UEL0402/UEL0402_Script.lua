local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')

local utilities = import('/lua/Utilities.lua')
local RandomFloat = utilities.GetRandomFloat
local EffectUtil = import('/lua/EffectUtilities.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateBoneEffects = import('/lua/effectutilities.lua').CreateBoneEffects
local WeaponSteam01 = import('/lua/effecttemplates.lua').WeaponSteam01

local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone

--Weapon local files
local TDFPlasmaCannonWeapon = WeaponsFile.TDFPlasmaCannonWeapon
local TDFHeavyPlasmaCannonWeapon = WeaponsFile.TDFHeavyPlasmaGatlingCannonWeapon
local TIFFragLauncherWeapon = import('/lua/terranweapons.lua').TDFFragmentationGrenadeLauncherWeapon

local Over_Charge = import('/mods/4DC/lua/4D_weapons.lua').Over_ChargeProjectile

local TANTorpedoAngler = WeaponsFile.TANTorpedoAngler

uel0402 = Class(TWalkingLandUnit) {

    Weapons = {
	
        Grenade = Class(TIFFragLauncherWeapon) {},	
	
        plasma_repeater = Class(TDFPlasmaCannonWeapon) {},    
		
        auto_cannon_right = Class(TDFHeavyPlasmaCannonWeapon) {
		
			OnCreate = function(self)
			
				TDFHeavyPlasmaCannonWeapon.OnCreate(self)
				
                if not self.SpinManip1 then 
				
                    self.SpinManip1 = CreateRotator(self.unit, 'auto_cannon_spinner_right', 'z', nil, 0, 360, 0)
                    self.unit.Trash:Add(self.SpinManip1)
                end
				
			end,
			
            PlayFxRackSalvoChargeSequence = function(self)

                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)

                self.SpinManip1:SetTargetSpeed(1440)
			
            end,			
			
            PlayFxRackSalvoReloadSequence = function(self)
			
                self.SpinManip1:SetTargetSpeed(360)			

				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_spinner_right', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_muzzle_right', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_barrel_right', Army, WeaponSteam01 )
				
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
			
            PlayFxWeaponPackSequence = function(self)
			
                self.SpinManip1:SetTargetSpeed(0)
				
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_spinner_right', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_muzzle_right', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_barrel_right', Army, WeaponSteam01 )				
				
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)

            end,
			
        },

        auto_cannon_left = Class(TDFHeavyPlasmaCannonWeapon) {
		
			OnCreate = function(self)
			
				TDFHeavyPlasmaCannonWeapon.OnCreate(self)
				
                if not self.SpinManip2 then 
				
                    self.SpinManip2 = CreateRotator(self.unit, 'auto_cannon_spinner_left', 'z', nil, 0, 360, 0)
                    self.unit.Trash:Add(self.SpinManip2)
                end
				
			end,
			
            PlayFxRackSalvoChargeSequence = function(self)

                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
			
                self.SpinManip2:SetTargetSpeed(1440)
				
            end,			
			
            PlayFxRackSalvoReloadSequence = function(self)

                self.SpinManip2:SetTargetSpeed(360)

				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_spinner_left', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_muzzle_left', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_barrel_left', Army, WeaponSteam01 )
				
                TDFHeavyPlasmaCannonWeapon.PlayFxRackSalvoChargeSequence(self)
            end,
			
            PlayFxWeaponPackSequence = function(self)
			
                self.SpinManip2:SetTargetSpeed(0)
				
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_spinner_left', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_muzzle_left', Army, WeaponSteam01 )
				self.ExhaustEffects = CreateBoneEffects( self.unit, 'auto_cannon_barrel_left', Army, WeaponSteam01 )				
				
                TDFHeavyPlasmaCannonWeapon.PlayFxWeaponPackSequence(self)

            end,
			
        },

		emp_right = Class(Over_Charge) {
		
			CreateProjectileAtMuzzle = function(self, muzzle)
			
				local proj = Over_Charge.CreateProjectileAtMuzzle(self, muzzle)
				local data = self:GetBlueprint().DamageToShields
				
				if proj and not proj:BeenDestroyed() then
					proj:PassData(data)
				end
				
			end,
			
			FxMuzzleFlashScale = 3,
		},
		
		emp_left = Class(Over_Charge) {
		
			CreateProjectileAtMuzzle = function(self, muzzle)
			
				local proj = Over_Charge.CreateProjectileAtMuzzle(self, muzzle)
				
				local data = self:GetBlueprint().DamageToShields
				
				if proj and not proj:BeenDestroyed() then
					proj:PassData(data)
				end
			end,
			
			FxMuzzleFlashScale = 3,
		},
		
		Torpedo = Class(TANTorpedoAngler) {},
	},

    OnCreate = function(self,builder,layer)
	
        TWalkingLandUnit.OnCreate(self)

        -- Creating Global Variables
        Army = self:GetArmy()
		
        --Disables user control until startup animation has completed
        self.SetUnSelectable(self, true)  
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        -- starts the animation sequence
        self:ForkThread(self.StompEffects)    
		
        local layer = self:GetCurrentLayer()
		
        self:CreateUnitAmbientEffect(layer)
		
        TWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
    end,

    StompEffects = function(self)
	
        local position = self:GetPosition()
		
        -- Big Thanks to Gilbot_X for his assistance with the Stomp Effects scripts
        self:PlayUnitSound('Roar')
		
        WaitSeconds( 2 )
		
        local effectsBag = {}
		
        for i = 1, 2 do
		
            self:PlayUnitSound('FootFallGeneric')
			
            table.insert(effectsBag, CreateAttachedEmitter(self, 'foot_left', Army, '/effects/emitters/dust_cloud_06_emit.bp' ))
			
            DamageRing(self, position, 0.1, 3, 10, 'Force', false)
			
            WaitSeconds( 0.5 )
			
            self:PlayUnitSound('FootFallGeneric')
			
            table.insert(effectsBag, CreateAttachedEmitter(self, 'foot_right', Army, '/effects/emitters/dust_cloud_06_emit.bp' ))
			
            DamageRing(self, position, 0.1, 3, 10, 'Force', false)
			
            WaitSeconds( 0.5 )
        end
		
        -- Clean up of Stomp effects
        for k,v in effectsBag do          
            v:Destroy()
        end     
		
        -- Enables user control after animation has completed
        self.SetUnSelectable(self, false)
		
    end,

    OnLayerChange = function(self, new, old)
	
        TWalkingLandUnit.OnLayerChange(self, new, old)
		
        if( new == 'Land' ) then
			
            self:CreateUnitAmbientEffect(new)

        elseif ( new == 'Seabed' ) then
			
            self:CreateUnitAmbientEffect(new)

        end
		
    end,

    AmbientLandExhaustBones = {'exhaust_left','exhaust_right',},  
   
    AmbientLandExhaustEffects = {
        '/effects/emitters/dirty_exhaust_smoke_02_emit.bp',
        '/effects/emitters/dirty_exhaust_sparks_02_emit.bp',  
    },

    AmbientSeaExhaustBones = {'leg_left','leg_right','slider_left','slider_right',},

    AmbientSeabedExhaustEffects = {
        '/effects/emitters/underwater_vent_bubbles_02_emit.bp',
        '/effects/emitters/underwater_move_trail_01_emit.bp',
    },

    AmbientWakeCenterBones = {'torso',},

    AmbientwakeCenterEffects = {
        '/effects/emitters/water_idle_ripples_03_emit.bp',
        '/effects/emitters/water_heat_ambient_01_emit.bp',
        '/effects/emitters/water_heat_ambient_02_emit.bp',
        '/effects/emitters/water_heat_ambient_03_emit.bp',    
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
		
            for kE, vE in self.AmbientSeabedExhaustEffects do
			
                for kB, vB in self.AmbientSeaExhaustBones do
				
                    table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, Army, vE ))
					
                end
				
            end
			
            for kE, vE in self.AmbientwakeCenterEffects do
			
                for kB, vB in self.AmbientWakeCenterBones do
				
                    table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, Army, vE ))
					
                end
				
            end 
			
        end
		
    end,

    UnitLandAmbientEffectThread = function(self)
	
        while not self.Dead do
		
            for kE, vE in self.AmbientLandExhaustEffects do
			
                for kB, vB in self.AmbientLandExhaustBones do
				
                    table.insert( self.AmbientExhaustEffectsBag, CreateAttachedEmitter(self, vB, Army, vE ))
					
                end
				
            end
			
            WaitSeconds(2)
			
            EffectUtil.CleanupEffectBag(self,'AmbientExhaustEffectsBag')
			
            WaitSeconds(utilities.GetRandomFloat(1,7))
			
        end
		
    end,

    DestroyOnKilled = false,

    -- Just tosses parts everywhere
    DestructionPartsHighToss = {
        'elbo_left','elbo_right','fore_arm_left','fore_arm_right','wrist_left','wrist_right','weapon_arm_left',
        'weapon_arm_right',
    },
	
    DestructionPartsLowToss = {
        'plasma_repeater_front_yaw','plasma_repeater_pitch','plasma_repeater_left','plasma_repeater_right',
        'plasma_repeater__slider_left','plasma_repeater__slider_right','shoulder_left','shoulder_right',
        'auto_cannon_spinner_left','auto_cannon_spinner_right','auto_cannon_barrel_left',
        'auto_cannon_barrel_right','pistons_arm_left','pistons_arm_right',
    },

    MechDestructionEffectBones = {
        'plasma_repeater_front_yaw','plasma_repeater_pitch','plasma_repeater_left','plasma_repeater_right',
        'plasma_repeater_slider_left','plasma_repeater_slider_right','shoulder_left','shoulder_right',
        'auto_cannon_spinner_left','auto_cannon_spinner_right','auto_cannon_barrel_left',
        'auto_cannon_barrel_right','pistons_arm_left','pistons_arm_right','elbo_left','elbo_right','fore_arm_left',
        'fore_arm_right','wrist_left','wrist_right','weapon_arm_left','weapon_arm_right','missile_L1','missile_L2',
        'missile_L3','missile_R1','missile_R2','missile_R3','missile_L4','missile_L5','missile_L6','missile_R4','missile_R5',
        'missile_L1','missile_L7','missile_L8','missile_R9','missile_R7','missile_R8','missile_R9','missile_L10','missile_L11',
        'missile_L12','missile_R10','missile_R11','missile_R12','missile_L13','missile_L14','missile_L15',
        'missile_R13','missile_R14','missile_R15','exhaust_left','exhaust_right',
    },

    OnKilled = function(self, inst, type, okr)
	
        self.Trash:Destroy()
        self.Trash = TrashBag()
		
        if self.AmbientExhaustEffectsBag then
            EffectUtil.CleanupEffectBag(self,'AmbientExhaustEffectsBag')
        end
		
        TWalkingLandUnit.OnKilled(self, inst, type, okr)
    end,

    CreateDamageEffects = function(self, bone, Army )
        for k, v in EffectTemplate.TNapalmCarpetBombHitLand01 do  
            CreateAttachedEmitter( self, bone, Army, v ):ScaleEmitter(0.3)
        end
    end,

    CreateExplosionDebris = function( self, Army )
        for k, v in EffectTemplate.ExplosionEffectsSml01 do
            CreateAttachedEmitter( self, 'uel0402', Army, v )
        end
    end,

    CreateFirePlumes = function( self, Army, bones, yBoneOffset )
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        for k, vBone in bones do
            position = self:GetPosition(vBone)
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition )  
            velocity.x = velocity.x + utilities.GetRandomFloat(-0.45, 0.45)
            velocity.z = velocity.z + utilities.GetRandomFloat(-0.45, 0.45)
            velocity.y = velocity.y + utilities.GetRandomFloat( 0.0, 0.45)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, -2)):SetVelocity(utilities.GetRandomFloat(1, 4)):SetCollision(false)            
            local emitter = CreateEmitterOnEntity(proj, Army, '/effects/emitters/destruction_explosion_fire_plume_01_emit.bp')
            local lifetime = utilities.GetRandomFloat( 7, 14 )
        end
    end,

    InitialRandomExplosions = function(self)
        local position = self:GetPosition()
        local numExplosions = math.floor( table.getn( self.MechDestructionEffectBones ) * 0.3 )

        -- Create small explosions all over
        for i = 0, numExplosions do
            local ranBone = utilities.GetRandomInt( 1, numExplosions )
            local duration = utilities.GetRandomFloat( 0.2, 0.5 )
            self:PlayUnitSound('Destroyed')
            explosion.CreateDefaultHitExplosionAtBone( self, self.MechDestructionEffectBones[ ranBone ], Random(0.125,0.5) )
            self:CreateFirePlumes( Army, {ranBone}, Random(0,2) )
            self:CreateDamageEffects( ranBone, Army )
            self:CreateExplosionDebris( Army )
            self:ShakeCamera(1, 0.5, 0.25, duration)
            WaitSeconds( duration )
        end

        -- Create main body explosions
        CreateDeathExplosion( self, 'missile_pod_left', Random(1,5))
        self:CreateDamageEffects( 'missile_pod_left', Army )
        self:ShakeCamera(2, 1, 0.5, 0.5)
        self:PlayUnitSound('Destroyed')  
        CreateDeathExplosion( self, 'missile_pod_right', Random(1,5))
        self:CreateDamageEffects( 'missile_pod_right', Army )
        self:ShakeCamera(2, 1, 0.5, 0.5)
        self:PlayUnitSound('Destroyed')
        WaitSeconds( 0.5 )
        CreateDeathExplosion( self, 'body', Random(1,10))
        self:CreateDamageEffects( 'body', Army )
        self:ShakeCamera(4, 2, 1, 1)
        self:PlayUnitSound('Destroyed')
    end,

    NukeExplosion = function(self)
        local position = self:GetPosition()

        -- Create full-screen glow flash
        self:PlayUnitSound('Nuke')
        CreateAttachedEmitter(self, 'uel0402', Army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):ScaleEmitter(0.2)
        self:ForkThread(self.CreateOuterRingWaveSmokeRing)
        CreateLightParticle(self, -1, Army, 10, 4, 'glow_02', 'ramp_red_02')
        WaitSeconds( 0.25 )
        CreateLightParticle(self, -1, Army, 10, 20, 'glow_03', 'ramp_fire_06')
        WaitSeconds( 0.55 )        
        CreateLightParticle(self, -1, Army, 20, 250, 'glow_03', 'ramp_nuke_04')
      
        -- Create ground decals
        local orientation = RandomFloat( 0, 2 * math.pi )
        CreateDecal(position, orientation, 'Crater01_albedo', '', 'Albedo', 8, 8, 400, 120, Army)
        CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', 8, 8, 400, 120, Army)      
        CreateDecal(position, orientation, 'nuke_scorch_003_albedo', '', 'Albedo', 12, 12, 400, 120, Army)
   
        -- Knockdown force rings
        DamageRing(self, position, 0.1, 20, 1, 'Force', false)
        WaitSeconds(0.1)

        -- Nuke damage and camera shake
        DamageRing(self, position, 0.1, 9, 1000, 'Force', true)
		DamageRing(self, position, 0.1, 6, 2000, 'Force', true)
		DamageRing(self, position, 0.1, 4, 3000, 'Force', true)
        self:ShakeCamera(6, 3, 2, 2)  
    end,

    CreateOuterRingWaveSmokeRing = function(self)
        local sides = 24
        local angle = (2*math.pi) / sides
        local velocity = 1.2
        local OffsetMod = 4
        local projectiles = {}
        for i = 0, (sides-1) do
            local X = math.sin(i*angle)
            local Z = math.cos(i*angle)
            local proj =  self:CreateProjectile('/effects/entities/SCUDeathShockwave01/SCUDeathShockwave01_proj.bp', X * OffsetMod , 2, Z * OffsetMod, X, 0, Z)
                :SetVelocity(velocity)
            table.insert( projectiles, proj )
        end       
        WaitSeconds( 3 )
        -- Slow projectiles down to normal speed
        for k, v in projectiles do
            v:SetAcceleration(-0.45)
        end        
    end,

    DeathThread = function(self)
	
        --Removes autocannon barrel spin effects
        if self.SpinManip then
            self.unit.Trash:Add(self.SpinManip)
        end
		
        -- Create Initial explosion effects
        self:InitialRandomExplosions()       
		
        -- Nuke detonation
        self:NukeExplosion()   
		
        -- Removes the unwanted bones and starts the corpse effects
        self:HideBone('body', true)
        self:CreateWreckage(Random(0.1,1))
        self:Destroy()
    end,
}
TypeClass = uel0402
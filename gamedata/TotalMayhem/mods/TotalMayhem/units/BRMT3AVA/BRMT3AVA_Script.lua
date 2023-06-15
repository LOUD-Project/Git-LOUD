local CWalkingLandUnit = import('/lua/defaultunits.lua').WalkingLandUnit

local WeaponsFile2 = import('/lua/terranweapons.lua')
local CWeapons = import('/lua/cybranweapons.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')

local CDFParticleCannonWeapon = CWeapons.CDFParticleCannonWeapon
local TDFGaussCannonWeapon = WeaponsFile2.TDFLandGaussCannonWeapon
local TDFRiotWeapon = WeaponsFile2.TDFRiotWeapon
local CDFProtonCannonWeapon = CWeapons.CDFProtonCannonWeapon

local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone

local utilities = import('/lua/Utilities.lua')


BRMT3AVA = Class(CWalkingLandUnit) {

    Weapons = {
		
        TopTurretCannon = Class(CDFProtonCannonWeapon) { FxMuzzleFlashScale = 4.1	},
		
        FrontTurretCannon = Class(CDFProtonCannonWeapon) { FxMuzzleFlashScale = 4.1 },
		
        laser1w = Class(CDFParticleCannonWeapon) {},
		
        laser2w = Class(CDFParticleCannonWeapon) {},
		
        mgweapon = Class(TDFRiotWeapon) {
			FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFxTank,
			FxMuzzleFlashScale = 0.75, 
        },
		
        rocket1 = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.1 },
		
        rocket2 = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 1.1 },
    },

	
	CreateDamageEffects = function(self, bone, army )
    
        for k, v in EffectTemplate.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end
        
        for k, v in EffectTemplate.DamageStructureFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end        
    end,	

    CreateDeathExplosionDustRing = function( self )
    
        local blanketSides = 18
        local blanketAngle = 6.28 / blanketSides
        local blanketStrength = 1
        local blanketVelocity = 2.8

        for i = 0, (blanketSides-1) do
            local blanketX = math.sin(i*blanketAngle)
            local blanketZ = math.cos(i*blanketAngle)

            local Blanketparts = self:CreateProjectile('/effects/entities/DestructionDust01/DestructionDust01_proj.bp', blanketX, 1.5, blanketZ + 4, blanketX, 0, blanketZ)
                :SetVelocity(blanketVelocity):SetAcceleration(-0.3)
        end        
    end,

    CreateFirePlumes = function( self, army, bones, yBoneOffset )
    
        local proj, position, offset, velocity
        local basePosition = self:GetPosition()
        
        for k, vBone in bones do
        
            position = self:GetPosition(vBone)
            
            offset = utilities.GetDifferenceVector( position, basePosition )
            velocity = utilities.GetDirectionVector( position, basePosition ) 
            
            velocity[1] = velocity[1] + utilities.GetRandomFloat(-0.3, 0.3)
            velocity[2] = velocity[2] + utilities.GetRandomFloat(-0.3, 0.3)
            velocity[3] = velocity[3] + utilities.GetRandomFloat( 0.0, 0.3)
            
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity[1], velocity[2], velocity[3])
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, -2)):SetVelocity(utilities.GetRandomFloat(3, 4)):SetCollision(false)
            
            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = utilities.GetRandomFloat( 12, 22 )
        end
    end,

    CreateExplosionDebris = function( self, army )
    
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, 'BRMT3AVA', army, v ):OffsetEmitter( 0, 5, 0 )
        end
    end,

    DeathThread = function(self)
    
        self:PlayUnitSound('Destroyed')
        
        local army = self.Army

        -- Create Initial explosion effects
        explosion.CreateFlash( self, 'rl02', 5.5, army )
        
        CreateAttachedEmitter(self, 'BRMT3AVA', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):OffsetEmitter( 0, 5, 0 )
        CreateAttachedEmitter(self,'BRMT3AVA', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp'):OffsetEmitter( 0, 5, 0 )
        CreateAttachedEmitter(self,'BRMT3AVA', army, '/effects/emitters/distortion_ring_01_emit.bp')
        
        self:CreateFirePlumes( army, {'rl02','rl03','Front_Turret','BRMT3AVA'}, 1.1 )
        
        self:CreateExplosionDebris( army )
        self:CreateExplosionDebris( army )
        
        WaitSeconds(0.5)
        
        -- Create damage effects on turret bone
        CreateDeathExplosion( self, 'Front_Turret01', 1.8)
        
        self:CreateDamageEffects( 'Front_Turret01', army )
        self:CreateDamageEffects( 'Front_Turret', army )

        WaitSeconds(0.3)
        
        self:CreateFirePlumes( army, {'legb11','legb08','legb25','legb28','head','rl01',}, 1 )
        
        self:CreateDeathExplosionDustRing()
        
        WaitSeconds(0.3)
        
        self:ShakeCamera(40, 4, 1, 3.2)
        
        self:CreateDamageEffects( 'head', 1.2)
        
        CreateDeathExplosion( self, 'lasergun02', 1.2)

        self:CreateExplosionDebris( army )

        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        local bp = __blueprints[self.BlueprintID]
        
        for i, numWeapons in bp.Weapon do
        
            if(bp.Weapon[i].Label == 'MegalithDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end

        -- Explosion on and damage fire on various bones
        CreateDeathExplosion( self, 'rl0' .. Random(1,4), 1)
        
        CreateDeathExplosion( self, 'AttachPoint', 2)
        
        self:CreateFirePlumes( army, {'Front_Turret01','Front_Turret','head'}, 1 )
        
        self:CreateDamageEffects( 'Front_Turret01', army )
        
        WaitSeconds(0.3)
        
        CreateDeathExplosion( self, 'legb17', 0.9)
        
        self:CreateDamageEffects( 'footfall02', army )
        
        WaitSeconds(0.3)
        
        CreateDeathExplosion( self, 'head', 1)
        
        self:CreateExplosionDebris( army )
        
        CreateDeathExplosion( self, 'footfall06', 0.9)
        
        self:CreateDamageEffects( 'frontmuzzle02', army )
        
        WaitSeconds(0.3)
        
        CreateDeathExplosion( self, 'footfall04', 1.25)
        
        CreateDeathExplosion( self, 'lasergunmuzzle01', 2 )
        
        self:CreateDamageEffects( 'lasergunmuzzle02', army )
        
        explosion.CreateFlash( self, 'gunbarrel05', 2.2, army )        

        self:CreateWreckage(0.3)

        self:Destroy()
    end,
    

}

TypeClass = BRMT3AVA

local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit

local WeaponsFile = import('/lua/terranweapons.lua')
local WeaponsFile2 = import('/lua/cybranweapons.lua')
local WeaponsFile3 = import('/mods/BattlePack/lua/BattlePackweapons.lua')

local CDFHvyProtonCannonWeapon = WeaponsFile2.CDFHvyProtonCannonWeapon
local CDFElectronBolterWeapon = WeaponsFile2.CDFElectronBolterWeapon

local MissileRedirect = import('/lua/defaultantiprojectile.lua').MissileRedirect

local TDFGaussCannonWeapon = WeaponsFile.TDFLandGaussCannonWeapon
local AAMicrowaveLaserGenerator = import('/mods/BattlePack/lua/BattlePackweapons.lua').AAMicrowaveLaserGenerator 

local MobileUnit = import('/lua/defaultunits.lua').MobileUnit

local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone
local EffectTemplate = import('/lua/EffectTemplates.lua')

local utilities = import('/lua/Utilities.lua')
local EffectUtil = import('/lua/EffectUtilities.lua')

local Entity = import('/lua/sim/Entity.lua').Entity

WRL1466 = Class(CWalkingLandUnit) {

    Weapons = {

		KillerCannon = Class(CDFHvyProtonCannonWeapon) {},
        
		Bolter = Class(CDFElectronBolterWeapon) {},

		AALaser = Class(AAMicrowaveLaserGenerator) {},

		Rockets = Class(TDFGaussCannonWeapon) { FxMuzzleFlashScale = 0.7 },	
    },
	
	OnStartBeingBuilt = function(self, builder, layer)
        CWalkingLandUnit.OnStartBeingBuilt(self, builder, layer)
        if not self.AnimationManipulator then
            self.AnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.AnimationManipulator)
        end
        self.AnimationManipulator:PlayAnim(self:GetBlueprint().Display.AnimationActivate, false):SetRate(0)
    end,
	
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
		
		if self.AnimationManipulator then
            self:SetUnSelectable(true)
            self.AnimationManipulator:SetRate(1)
            
            self:ForkThread(function()
                WaitSeconds(self.AnimationManipulator:GetAnimationDuration()*self.AnimationManipulator:GetRate())
                self:SetUnSelectable(false)
                self.AnimationManipulator:Destroy()
            end)
        end
    end,
	
	    CreateDamageEffects = function(self, bone, army )
        for k, v in EffectTemplate.DamageFireSmoke01 do
            CreateAttachedEmitter( self, bone, army, v ):ScaleEmitter(1.5)
        end
    end,	

    CreateDeathExplosionDustRing = function( self )
        local blanketSides = 18
        local blanketAngle = (2*math.pi) / blanketSides
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
            velocity = utilities.GetDirectionVector( position, basePosition ) # 
            velocity.x = velocity.x + utilities.GetRandomFloat(-0.3, 0.3)
            velocity.z = velocity.z + utilities.GetRandomFloat(-0.3, 0.3)
            velocity.y = velocity.y + utilities.GetRandomFloat( 0.0, 0.3)
            proj = self:CreateProjectile('/effects/entities/DestructionFirePlume01/DestructionFirePlume01_proj.bp', offset.x, offset.y + yBoneOffset, offset.z, velocity.x, velocity.y, velocity.z)
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, -2)):SetVelocity(utilities.GetRandomFloat(3, 4)):SetCollision(false)
            
            local emitter = CreateEmitterOnEntity(proj, army, '/effects/emitters/destruction_explosion_fire_plume_02_emit.bp')

            local lifetime = utilities.GetRandomFloat( 12, 22 )
        end
    end,

    CreateExplosionDebris = function( self, army )
        for k, v in EffectTemplate.ExplosionDebrisLrg01 do
            CreateAttachedEmitter( self, 'XRL0403', army, v ):OffsetEmitter( 0, 5, 0 )
        end
    end,

    DeathThread = function(self)
        self:PlayUnitSound('Destroyed')
        
        local army = self:GetArmy()

        -- Create Initial explosion effects
        explosion.CreateFlash( self, 'Left_Leg01_B01', 3.5, army )
        
        CreateAttachedEmitter(self, 'XRL0403', army, '/effects/emitters/destruction_explosion_concussion_ring_03_emit.bp'):OffsetEmitter( 0, 5, 0 )
        CreateAttachedEmitter(self,'XRL0403', army, '/effects/emitters/explosion_fire_sparks_02_emit.bp'):OffsetEmitter( 0, 5, 0 )
        CreateAttachedEmitter(self,'XRL0403', army, '/effects/emitters/distortion_ring_01_emit.bp')
        
        self:CreateFirePlumes( army, {'XRL0403'}, 0 )

        --self:CreateFirePlumes( army, {'Right_Leg01_B01','Right_Leg02_B01','Left_Leg02_B01',}, 0.5 )

        WaitSeconds(0.4)
        
        -- Create damage effects on turret bone
        CreateDeathExplosion( self, 'MainTurret_Yaw', 1.5)
        
        self:CreateDamageEffects( 'MainTurret_Yaw', army )
        self:CreateDamageEffects( 'Right_Turret001', army )

        WaitSeconds(0.2)
        
        self:CreateFirePlumes( army, {'Right_Leg01_B01','Right_Leg02_B01','Left_Leg02_B01',}, 0.5 )
        self:CreateDeathExplosionDustRing()
        
        WaitSeconds(0.2)

        # When the spider bot impacts with the ground
        # Effects: Explosion on turret, dust effects on the muzzle tip, large dust ring around unit
        # Other: Damage force ring to force trees over and camera shake
        
        self:ShakeCamera(40, 4, 1, 3.8)
        
        CreateDeathExplosion( self, 'Left_Turret001', 1)

        self:CreateExplosionDebris( army )

        local x, y, z = unpack(self:GetPosition())
        z = z + 3
        
        DamageRing(self, {x,y,z}, 0.1, 3, 1, 'Force', true)

        local bp = self:GetBlueprint()
        
        for i, numWeapons in bp.Weapon do
            if(bp.Weapon[i].Label == 'MegalithDeath') then
                DamageArea(self, self:GetPosition(), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end
        end

        -- Explosion on and damage fire on various bones
        CreateDeathExplosion( self, 'Right_Leg0' .. Random(1,2) .. '_B02', 0.25)
        
        CreateDeathExplosion( self, 'Right_Turret_Muzzle01', 2)
        
        self:CreateFirePlumes( army, {'Right_Turret_Muzzle01'}, -1 )
        
        self:CreateDamageEffects( 'Right_Turret001', army )
        
        WaitSeconds(0.2)
        
        CreateDeathExplosion( self, 'Left_Leg0' .. Random(1,2) .. '_B01', 0.25)
        
        self:CreateDamageEffects( 'Right_Footfall_02', army )
        
        WaitSeconds(0.2)
        
        CreateDeathExplosion( self, 'Left_Turret_Muzzle01', 1)
        
        self:CreateExplosionDebris( army )
        
        CreateDeathExplosion( self, 'Right_Leg0' .. Random(1,2) .. '_B02', 0.25)
        
        self:CreateDamageEffects( 'Left_Turret_Muzzle02', army )
        
        WaitSeconds(0.2)
        
        CreateDeathExplosion( self, 'Left_Leg0' .. Random(1,2) .. '_B01', 0.25)
        
        CreateDeathExplosion( self, 'Right_Turret_Muzzle01', 2 )
        
        self:CreateDamageEffects( 'NewLeg', army )
        
        explosion.CreateFlash( self, 'Right_Leg01_B04', 2.2, army )        

        self:CreateWreckage(0.1)

        self:Destroy()
    end,
    
    
    OnMotionHorzEventChange = function( self, new, old )
        CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        
        if ( old == 'Stopped' ) then
            local bpDisplay = self:GetBlueprint().Display
            if bpDisplay.AnimationWalk and self.Animator then
                self.Animator:SetDirectionalAnim(true)
                self.Animator:SetRate(bpDisplay.AnimationWalkRate)
            end
         end
    end,
}

TypeClass = WRL1466

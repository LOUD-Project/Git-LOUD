local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit

local utilities = import('/lua/utilities.lua')
local RandomFloat = utilities.GetRandomFloat
local EffectTemplate = import('/lua/EffectTemplates.lua')
local explosion = import('/lua/defaultexplosions.lua')
local CreateDeathExplosion = explosion.CreateDefaultHitExplosionAtBone

-- Local weapon files
local WeaponsFile = import ('/lua/aeonweapons.lua')

local ADFPhasonLaser = WeaponsFile.ADFPhasonLaser
local ADFGravitonProjectorWeapon = WeaponsFile.ADFGravitonProjectorWeapon
local ADFLaserHighIntensityWeapon = WeaponsFile.ADFLaserHighIntensityWeapon
local AAAZealotMissileWeapon = WeaponsFile.AAAZealotMissileWeapon
local ADFChronoDampener = WeaponsFile.ADFChronoDampener

UAL0402 = Class(AWalkingLandUnit) {

    Weapons = {
    
        RightArm = Class(ADFPhasonLaser) {},
        
        LeftArm = Class(ADFLaserHighIntensityWeapon) {},
        
        Shoulder = Class(ADFGravitonProjectorWeapon) {},
        
        AA = Class(AAAZealotMissileWeapon) {},
        
        ChronoDampener = Class(ADFChronoDampener) {},        
    },

    OnCreate = function(self,builder,layer)
        AWalkingLandUnit.OnCreate(self)
        self:SetWeaponEnabledByLabel('ChronoDampener', false)
        Army = self:GetArmy()
    end,
    
    CreateEnhancement = function(self, enh)
        AWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        --Chrono Dampener
        if enh == 'ChronoDampener' then
            self:SetWeaponEnabledByLabel('ChronoDampener', true)
        elseif enh == 'ChronoDampenerRemove' then
            self:SetWeaponEnabledByLabel('ChronoDampener', false)
        end
    end,    
   
    OnAnimCollision = function(self, bone, x, y, z)
        AWalkingLandUnit.OnAnimCollision(self, bone, x, y, z)         
    end,

    DestructionEffectBones = {
        'Right_Leg_B01','Left_Leg_B01','ShoulderCannon','Right_Leg_B02','Left_Leg_B02','ArmRight','ArmLeft','ShoulderTurret','Right_Foot','Left_Foot','ShoulderBarrel',
        'WeaponRight','WeaponLeft','BarrelLeft','Missile2','Missile3','Missile1','MuzzleShoulder','MuzzleRight','MuzzleLeft',
    },
 
    CreateDamageEffects = function(self, bone, Army )
        for k, v in EffectTemplate.AMiasmaField01 do   
            CreateAttachedEmitter( self, bone, Army, v ):ScaleEmitter(0.5)
        end
    end,

    CreateExplosionDebris = function( self, bone, Army )
        for k, v in EffectTemplate.ExplosionEffectsSml01 do
            CreateAttachedEmitter( self, bone, Army, v ):ScaleEmitter(1.5)
        end
    end,
    
    CreateFirePlumesAeons = function( self, Army, bones, yBoneOffset )
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
            proj:SetBallisticAcceleration(utilities.GetRandomFloat(-1, 1)):SetVelocity(utilities.GetRandomFloat(1, 2)):SetCollision(false)           
            local emitter = CreateEmitterOnEntity(proj, Army, '/mods/4DC/effects/emitters/destruction_explosion_fire_plume_03_emit.bp')
            local lifetime = utilities.GetRandomFloat( 5, 25 )
        end
    end,

	InitialRandomExplosionsAeons = function(self)
        local position = self:GetPosition()
        local numExplosions =  math.floor( table.getn( self.DestructionEffectBones ) * 0.9 )
		CreateAttachedEmitter(self, 0, self:GetArmy(), '/effects/emitters/nuke_concussion_ring_01_emit.bp'):ScaleEmitter(0.175)
        -- Create small explosions all over
        for i = 0, numExplosions do
            local ranBone = utilities.GetRandomInt( 1, numExplosions )
            local duration = utilities.GetRandomFloat( 0.2, 0.5 )
            self:CreateFirePlumesAeons( Army, {ranBone}, Random(0,2) )
            self:CreateDamageEffects( ranBone, Army )
            self:ShakeCamera(2, 0.5, 0.25, duration)
            WaitSeconds( duration )
            self:CreateFirePlumesAeons( Army, {ranBone}, Random(0,2) )
        end
    end,

    DeathThread = function( self, overkillRatio , instigator)
        -- Create Initial explosion effects
        self:PlayUnitSound('Destroyed')
        self:InitialRandomExplosionsAeons()   
     	
        if self.DeathAnimManip then
            WaitFor(self.DeathAnimManip)
        end
        WaitSeconds(0.5)
        explosion.CreateDefaultHitExplosionAtBone( self, 'UAL0402', 5.0 )
        WaitSeconds(0.5)
        self:DestroyAllDamageEffects()
        self:CreateWreckage( overkillRatio )

        CreateAttachedEmitter(self, 1, Army, '/effects/emitters/shockwave_smoke_01_emit.bp' )
        -- Starts the corpse effects
        if( self.ShowUnitDestructionDebris and overkillRatio ) then
            if overkillRatio <= 1 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 2 then
                self.CreateUnitDestructionDebris( self, true, true, false )
            elseif overkillRatio <= 3 then
                self.CreateUnitDestructionDebris( self, true, true, true )
            else 
                self.CreateUnitDestructionDebris( self, true, true, true )
            end
        end

        self:PlayUnitSound('Destroyed')
        self:Destroy()
    end,
   
}
TypeClass = UAL0402
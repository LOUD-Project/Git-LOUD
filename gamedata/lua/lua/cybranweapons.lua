---  /lua/cybranweapons.lua

local BareBonesWeapon           = import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon
local KamikazeWeapon            = import('/lua/sim/DefaultWeapons.lua').KamikazeWeapon
local DefaultBeamWeapon         = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local DefaultProjectileWeapon   = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

local DefaultBeamWeaponOnCreate     = DefaultBeamWeapon.OnCreate
local DefaultBeamWeaponIdleState    = DefaultBeamWeapon.IdleState

local CollisionBeamFile         = import('defaultcollisionbeams.lua')

local EffectTemplate            = import('/lua/EffectTemplates.lua')

local Entity                    = import('/lua/sim/Entity.lua').Entity

local CreateAttachedEmitter = CreateAttachedEmitter
local CreateProjectile = moho.weapon_methods.CreateProjectile

local BeenDestroyed = moho.entity_methods.BeenDestroyed

local TrashAdd = TrashBag.Add

CybranBuffField = Class( import('/lua/defaultbufffield.lua').DefaultBuffField ) {
	AmbientEffects = '/effects/emitters/jammer_ambient_01_emit.bp',
    FieldVisualEmitter = '/effects/emitters/jammer_ambient_02_emit.bp',
	VisualScale = 0.5
}



CAABurstCloudFlakArtilleryWeapon        = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp' 
    },
    
    FxMuzzleFlashScale = 1.5,

    CreateProjectileForWeapon = function(self, bone)
    
        local projectile = CreateProjectile( self, bone )
        
        local damageTable = self.damageTable
        
        local blueprint = self.bp
        local data = false
        
        if blueprint.DoTDamage then
        
            data = {
                Damage = blueprint.DoTDamage,
                Duration = blueprint.DoTDuration,
                Frequency = blueprint.DoTFrequency,
                Radius = blueprint.DamageRadius,
                Type = 'Normal',
                DamageFriendly = blueprint.DamageFriendly,
            }
        end
        
        if projectile and not BeenDestroyed(projectile) then
            if data then
                projectile:PassData(data)
            end
            projectile:PassDamageData(damageTable)
        end
        
        return projectile
    end,
}

CAMEMPMissileWeapon                     = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/missile_sam_muzzle_flash_01_emit.bp'} }

CAANanoDartWeapon                       = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/cannon_muzzle_flash_04_emit.bp',
        '/effects/emitters/cannon_muzzle_smoke_11_emit.bp',
    },
}

CANNaniteTorpedoWeapon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },

    CreateProjectileForWeapon = function(self, bone)
    
        local projectile = DefaultProjectileWeapon.CreateProjectileForWeapon( self, bone )
        
        local damageTable = self.damageTable
        
        local bp = self.bp
        local data = false
        
        if bp.DoTDamage then
        
            data = {
                Damage = bp.DoTDamage,
                Duration = bp.DoTDuration,
                Frequency = bp.DoTFrequency,
                Type = 'Normal',
                PreDamageEffects = {},
                DuringDamageEffects = {},
                PostDamageEffects = {},
            }
        end
        
        if projectile and not BeenDestroyed(projectile) then

            if data then
                projectile:PassData(data)
            end

            projectile:PassDamageData(damageTable)
        end
        
        return projectile
    end,
}

CCannonMolecularWeapon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CMolecularRipperFlash01}

CDFElectronBolterWeapon                 = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CElectronBolterMuzzleFlash01}

CDFHeavyDisintegratorWeapon             = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/disintegratorhvy_muzzle_flash_01_emit.bp',
		'/effects/emitters/disintegratorhvy_muzzle_flash_02_emit.bp',
		'/effects/emitters/disintegratorhvy_muzzle_flash_03_emit.bp',
		'/effects/emitters/disintegratorhvy_muzzle_flash_04_emit.bp',
		'/effects/emitters/disintegratorhvy_muzzle_flash_05_emit.bp',
	},
}

CDFHeavyElectronBolterWeapon            = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CElectronBolterMuzzleFlash02}

CDFHvyProtonCannonWeapon                = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CHvyProtonCannonMuzzleflash}

CDFLaserPulseLightWeapon                = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CLaserMuzzleFlash01}

CDFLaserHeavyWeapon                     = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CLaserMuzzleFlash02}

CDFLaserHeavyWeapon02                   = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CLaserMuzzleFlash03}

CDFLaserDisintegratorWeapon01           = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/disintegrator_muzzle_flash_01_emit.bp',
		'/effects/emitters/disintegrator_muzzle_flash_02_emit.bp',
		'/effects/emitters/disintegrator_muzzle_flash_03_emit.bp',
	},
    FxChargeMuzzleFlash = {
		'/effects/emitters/disintegrator_muzzle_charge_01_emit.bp',
		'/effects/emitters/disintegrator_muzzle_charge_02_emit.bp',
        '/effects/emitters/disintegrator_muzzle_charge_05_emit.bp',
    },
}

CDFLaserDisintegratorWeapon02           = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/disintegrator_muzzle_flash_04_emit.bp',
        '/effects/emitters/disintegrator_muzzle_flash_05_emit.bp',
    },
    FxChargeMuzzleFlash = {
		'/effects/emitters/disintegrator_muzzle_charge_03_emit.bp',
        '/effects/emitters/disintegrator_muzzle_charge_04_emit.bp',
    },
}

CDFOverchargeWeapon                     = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CMolecularRipperOverChargeFlash01}

CDFProtonCannonWeapon                   = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/proton_cannon_muzzle_01_emit.bp',
                     '/effects/emitters/proton_cannon_muzzle_02_emit.bp',},
}

CDFRocketIridiumWeapon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/muzzle_flash_01_emit.bp'} }

CDFRocketIridiumWeapon02                = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/cybran_hoplight_muzzle_smoke_01_emit.bp',
	    '/effects/emitters/muzzle_flash_01_emit.bp',
	},
}

CIFArtilleryWeapon                      = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CArtilleryFlash01}

CIFBombNeutronWeapon                    = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp'} }

CIFGrenadeWeapon                        = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp'} }

CIFMissileCorsairWeapon                 = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/muzzle_flash_01_emit.bp'} }

CIFMissileLoaTacticalWeapon             = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/cybran_tactical_missile_launch_01_emit.bp',
        '/effects/emitters/cybran_tactical_missile_launch_02_emit.bp',
    },
}

CIFMissileLoaWeapon                     = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CIFCruiseMissileLaunchSmoke}

CIFNaniteTorpedoWeapon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp',},
    
    CreateProjectileForWeapon = function(self, bone)
    
        local proj = CreateProjectile( self, bone )
        
        local damageTable = self.damageTable
        
        local bp = self.bp
        local data = false
        
        if bp.DoTDamage then
        
            data = {
                Damage = bp.DoTDamage,
                Duration = bp.DoTDuration,
                Frequency = bp.DoTFrequency,
                Type = 'Normal',
                PreDamageEffects = {},
                DuringDamageEffects = {},
                PostDamageEffects = {},
            }
        end

        if proj and not BeenDestroyed(proj) then
            proj:PassDamageData(damageTable)
            
            if data then
                proj:PassData(data)
            end
        end
        
        return proj
    end,
}

CIFSmartCharge                          = Class(DefaultProjectileWeapon) {
	
    CreateProjectileAtMuzzle = function(self, muzzle)
	
        local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
		
        if not proj or BeenDestroyed(proj) then
            return proj
        end
		
        local tbl = self.bp.DepthCharge
		
        proj:AddDepthCharge(tbl)
    end,
}

CKrilTorpedoLauncherWeapon              = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.CKrilTorpedoLauncherMuzzleFlash01}



----- Bare Bones & Kamikaze Weapons -----

CIFCommanderDeathWeapon             = Class(BareBonesWeapon) {

    FiringMuzzleBones = {0}, -- just fire from the base bone of the unit

    OnCreate = function(self)
    
        BareBonesWeapon.OnCreate(self)
        
        local myBlueprint = self.bp
        
        -- The "or x" is supplying default values in case the blueprint doesn't have an overriding value
        self.Data = {
            NukeOuterRingDamage = myBlueprint.NukeOuterRingDamage or 10,
            NukeOuterRingRadius = myBlueprint.NukeOuterRingRadius or 40,
            NukeOuterRingTicks = myBlueprint.NukeOuterRingTicks or 20,
            NukeOuterRingTotalTime = myBlueprint.NukeOuterRingTotalTime or 10,

            NukeInnerRingDamage = myBlueprint.NukeInnerRingDamage or 2000,
            NukeInnerRingRadius = myBlueprint.NukeInnerRingRadius or 30,
            NukeInnerRingTicks = myBlueprint.NukeInnerRingTicks or 24,
            NukeInnerRingTotalTime = myBlueprint.NukeInnerRingTotalTime or 24,
        }
        self:SetWeaponEnabled(false)
    end,
	
    OnFire = function(self)
    end,
    
    Fire = function(self)
       
        local myProjectile = self.unit:CreateProjectile( self.bp.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
        
        myProjectile:PassDamageData(self.damageTable)
        
        if self.Data then
            myProjectile:PassData(self.Data)
        end
    end,
}

CMobileKamikazeBombWeapon           = Class(KamikazeWeapon){

	FxDeath = EffectTemplate.CMobileKamikazeBombExplosion,

    OnFire = function(self)
    
		local army = self.unit.Army
        
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end   

		KamikazeWeapon.OnFire(self)
    end,
}

CMobileKamikazeBombDeathWeapon      = Class(BareBonesWeapon) {

	FxDeath = EffectTemplate.CMobileKamikazeBombDeathExplosion,
    
    OnCreate = function(self)
        BareBonesWeapon.OnCreate(self)
        self:SetWeaponEnabled(false)   
    end,
    

    OnFire = function(self)
    end,
    
    Fire = function(self)
    
		local army = self.unit.Army
        
        for k, v in self.FxDeath do
            CreateEmitterAtBone(self.unit,-2,army,v)
        end 

		local myBlueprint = self.bp
        
        DamageArea(self.unit, self.unit:GetPosition(), myBlueprint.DamageRadius, myBlueprint.Damage, myBlueprint.DamageType or 'Normal', myBlueprint.DamageFriendly or false)
    end,    
}


----- Beam Weapons -----

CAMZapperWeapon                     = Class(DefaultBeamWeapon) { BeamType = CollisionBeamFile.ZapperCollisionBeam,
    FxMuzzleFlash = {'/effects/emitters/cannon_muzzle_flash_01_emit.bp',},

    SphereEffectIdleMesh = '/effects/entities/cybranphalanxsphere01/cybranphalanxsphere01_mesh',
    SphereEffectActiveMesh = '/effects/entities/cybranphalanxsphere01/cybranphalanxsphere02_mesh',
    SphereEffectBp = '/effects/emitters/zapper_electricity_01_emit.bp',
    SphereEffectBone = 'Turret_Muzzle',
    
    OnCreate = function(self)
    
        DefaultBeamWeaponOnCreate(self)

        local unit      = self.unit

        self.SphereEffectEntity = Entity()
        
        local Muzzle    = self.bp.RackBones[1].MuzzleBones[1]
        local Sphere    = self.SphereEffectEntity

        
        Sphere:AttachBoneTo( -1, unit, Muzzle )
        Sphere:SetMesh( self.SphereEffectIdleMesh )
        Sphere:SetDrawScale( 0.55 )
        
        Sphere:SetVizToAllies('Intel')
        Sphere:SetVizToNeutrals('Intel')
        Sphere:SetVizToEnemies('Intel')
        
        local emit = CreateAttachedEmitter( unit, Muzzle, unit.Army, self.SphereEffectBp )

        TrashAdd( unit.Trash, Sphere )
        TrashAdd( unit.Trash, emit )
    end,

    IdleState = State (DefaultBeamWeaponIdleState) {
    
        Main = function(self)
            DefaultBeamWeaponIdleState.Main(self)
        end,

        OnGotTarget = function(self)
        
            DefaultBeamWeaponIdleState.OnGotTarget(self)
            
            self.SphereEffectEntity:SetMesh(self.SphereEffectActiveMesh)
        end,
    },
--[[
    OnLostTarget = function(self)
    
        DefaultBeamWeapon.OnLostTarget(self)
        
        self.SphereEffectEntity:SetMesh(self.SphereEffectIdleMesh)
    end,
--]]
}

CAMZapperWeapon02                   = Class(DefaultBeamWeapon) { BeamType = CollisionBeamFile.ZapperCollisionBeam,
    FxMuzzleFlash = {'/effects/emitters/cannon_muzzle_flash_01_emit.bp',},
}

CDFAAMicrowaveLaser                 = Class(DefaultBeamWeapon) { BeamType = CollisionBeamFile.MicrowaveLaserCollisionBeam03,

    TerrainImpactScale = 0.2,
    FxBeamStartPointScale = 0.2,
    FxMuzzleFlashScale = 0.2,
 }

CDFHeavyMicrowaveLaserGenerator     = Class(DefaultBeamWeapon) { BeamType = CollisionBeamFile.MicrowaveLaserCollisionBeam01,

    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,

    IdleState = State(DefaultBeamWeaponIdleState) {
    
        Main = function(self)
            if self.RotatorManip then
                self.RotatorManip:SetSpeed(0)
            end
            if self.SliderManip then
                self.SliderManip:SetGoal(0,0,0)
                self.SliderManip:SetSpeed(2)
            end
            DefaultBeamWeaponIdleState.Main(self)
        end,
    },

    CreateProjectileAtMuzzle = function(self, muzzle)
    
        if not self.SliderManip then
            self.SliderManip = CreateSlider(self.unit, 'Center_Turret_Barrel')
            TrashAdd( self.unit.Trash, self.SliderManip )
        end
        
        if not self.RotatorManip then
            self.RotatorManip = CreateRotator(self.unit, 'Center_Turret_Barrel', 'z')
            TrashAdd( self.unit.Trash, self.RotatorManip )
        end
        
        self.RotatorManip:SetSpeed(180)

        self.SliderManip:SetPrecedence(11)
        self.SliderManip:SetGoal(0, 0, -1)
        self.SliderManip:SetSpeed(-1)
        
        DefaultBeamWeapon.CreateProjectileAtMuzzle(self, muzzle)
    end,

    PlayFxWeaponUnpackSequence = function( self )
    
        if not self.ContBeamOn then
        
            local army = self.unit.Army
            local bp = self.bp
            
			local CreateAttachedEmitter = CreateAttachedEmitter
			
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackNumber].MuzzleBones do 
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)  
                end
            end
            
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

CDFHeavyMicrowaveLaserGeneratorCom  = Class(DefaultBeamWeapon) { BeamType = CollisionBeamFile.MicrowaveLaserCollisionBeam02,

    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
        
        local army = self.unit.Army
        local bp = self.bp
        
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        for k, v in self.FxUpackingChargeEffects do
        
            for ek, ev in bp.RackBones[self.CurrentRackNumber].MuzzleBones do 
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)  
            end
        end
        
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

CDFParticleCannonWeapon             = Class(DefaultBeamWeapon) { BeamType = CollisionBeamFile.ParticleCannonCollisionBeam,
    FxMuzzleFlash = {'/effects/emitters/particle_cannon_muzzle_01_emit.bp'},
}

CybranTargetPainter                 = Class(DefaultBeamWeapon) { FxMuzzleFlash = false }

CollisionBeamFile = nil
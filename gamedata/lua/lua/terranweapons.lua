---  /lua/terranweapons.lua
---  Terran-specific weapon definitions

local BareBonesWeapon           = import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon
local DefaultBeamWeapon         = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon
local DefaultProjectileWeapon   = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

local OrbitalDeathLaserCollisionBeam    = import('defaultcollisionbeams.lua').OrbitalDeathLaserCollisionBeam
local TDFHiroCollisionBeam              = import('defaultcollisionbeams.lua').TDFHiroCollisionBeam

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateAttachedEmitter = CreateAttachedEmitter

TAAFlakArtilleryCannon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TFlakCannonMuzzleFlash01,
    
    -- Custom over-ride for this weapon, so it passes data and damageTable
    CreateProjectileForWeapon = function(self, bone)
    
        local proj = self:CreateProjectile(bone)
        local damageTable = self.damageTable
        
        local blueprint = self.bp
        local data = false
        
        if blueprint.DOTDamage then
        
            data = {

                Damage = blueprint.DoTDamage,
                Duration = blueprint.DoTDuration,
                Frequency = blueprint.DoTFrequency,
                Radius = blueprint.DamageRadius,
                Type = 'Normal',
                DamageFriendly = blueprint.DamageFriendly,
            }
        end

        if proj and not proj:BeenDestroyed() then
        
            proj:PassDamageData(damageTable)
            
            if data then
                proj:PassData(data)
            end
        end

        return proj
    end
}

TAALinkedRailgun                        = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TRailGunMuzzleFlash01 }

TAMInterceptorWeapon                    = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/terran_antinuke_launch_01_emit.bp'} }

TAMPhalanxWeapon                        = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TPhalanxGunMuzzleFlash,
    FxShellEject  = EffectTemplate.TPhalanxGunShells,

    PlayFxMuzzleSequence = function(self, muzzle)
    
        local army = self.unit.Army
        local bp = self.bp
        
		local CreateAttachedEmitter = CreateAttachedEmitter
		
		DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
        
		for _, v in self.FxShellEject do
            CreateAttachedEmitter(self.unit, bp.TurretBonePitch, army, v):ScaleEmitter(self.FxMuzzleFlashScale)
        end
    end,
}

TANTorpedoAngler                        = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },
}

TDFFragmentationGrenadeLauncherWeapon   = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.THeavyFragmentationGrenadeMuzzleFlash }

TDFPlasmaCannonWeapon                   = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TPlasmaGatlingCannonMuzzleFlash }

TDFLightPlasmaCannonWeapon              = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TPlasmaCannonLightMuzzleFlash }

TDFHeavyPlasmaCannonWeapon              = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TPlasmaCannonHeavyMuzzleFlash }

TDFOverchargeWeapon                     = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TCommanderOverchargeFlash01 }

TDFMachineGunWeapon                     = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/machinegun_muzzle_fire_01_emit.bp',
        '/effects/emitters/machinegun_muzzle_fire_02_emit.bp',
    },
}

TDFGaussCannonWeapon                    = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TGaussCannonFlash}

TDFShipGaussCannonWeapon                = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TShipGaussCannonFlash}

TDFLandGaussCannonWeapon                = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TLandGaussCannonFlash}

TDFZephyrCannonWeapon                   = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TLaserMuzzleFlash}

TDFRiotWeapon                           = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TRiotGunMuzzleFx}

TDFIonizedPlasmaCannon                  = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TIonizedPlasmaGatlingCannonMuzzleFlash}

TIFArtilleryWeapon                      = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TIFArtilleryMuzzleFlash }

TIFCarpetBombWeapon                     = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp'},

    CreateProjectileForWeapon = function(self, bone)
        local projectile = self:CreateProjectile(bone)
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
        
        if projectile and not projectile:BeenDestroyed() then
            if data then
                projectile:PassData(data)
            end
            projectile:PassDamageData(damageTable)
        end
        
        return projectile
    end,
}

TIFCruiseMissileLauncher                = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchSmoke}

TIFCruiseMissileLauncherSub             = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TIFCruiseMissileLaunchUnderWater}

TIFHighBallisticMortarWeapon            = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TMobileMortarMuzzleEffect01 }

TIFSmallYieldNuclearBombWeapon          = Class(DefaultProjectileWeapon) { FxMuzzleFlash = {'/effects/emitters/antiair_muzzle_fire_02_emit.bp'} }

TIFSmartCharge                          = Class(DefaultProjectileWeapon) {

    CreateProjectileAtMuzzle = function(self, muzzle)
        local proj = DefaultProjectileWeapon.CreateProjectileAtMuzzle(self, muzzle)
        local tbl = self.bp.DepthCharge
        proj:AddDepthCharge(tbl)
    end,
}

TSAMLauncher                            = Class(DefaultProjectileWeapon) { FxMuzzleFlash = EffectTemplate.TAAMissileLaunch}



TDFHiroPlasmaCannon                     = Class(DefaultBeamWeapon) { BeamType = TDFHiroCollisionBeam,

    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 1,

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

TOrbitalDeathLaserBeamWeapon            = Class(DefaultBeamWeapon) { BeamType = OrbitalDeathLaserCollisionBeam,
    
    FxUpackingChargeEffects = {},
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
    
        local army = self.unit.Army
        local bp = self.bp
        
        local CreateAttachedEmitter = CreateAttachedEmitter
		
        for _, v in self.FxUpackingChargeEffects do
            for _, ev in bp.RackBones[self.CurrentRackNumber].MuzzleBones do
                CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
            end
        end
        
        DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
    end,
}

TerranTargetPainter                     = Class(DefaultBeamWeapon) { FxMuzzleFlash = false }


TIFCommanderDeathWeapon                 = Class(BareBonesWeapon) {

    FiringMuzzleBones = {0}, -- just fire from the base bone of the unit

    OnCreate = function(self)
    
        BareBonesWeapon.OnCreate(self)
        
        local myBlueprint = self.bp
        
        --# The "or x" is supplying default values in case the blueprint doesn't have an overriding value
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
    
        local myBlueprint = self.bp
        local myProjectile = self.unit:CreateProjectile( myBlueprint.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
        
        myProjectile:PassDamageData(self.damageTable)
        
        if self.Data then
            myProjectile:PassData(self.Data)
        end
    end,

}

--[[
TANTorpedoLandWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = {
		'/effects/emitters/default_muzzle_flash_01_emit.bp',
        '/effects/emitters/default_muzzle_flash_02_emit.bp',
        '/effects/emitters/torpedo_underwater_launch_01_emit.bp',
    },
}

--TAAGinsuRapidPulseWeapon                = Class(DefaultProjectileWeapon) {}

--TIFCruiseMissileUnpackingLauncher       = Class(DefaultProjectileWeapon) {}

--TIFStrategicMissileWeapon               = Class(DefaultProjectileWeapon) {}

--]]

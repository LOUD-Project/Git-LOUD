---  /lua/seraphimweapons.lua
---  Summary  :  Default definitions of Seraphim weapons

local KamikazeWeapon = import('/lua/sim/DefaultWeapons.lua').KamikazeWeapon
local BareBonesWeapon = import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon
local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon
local DefaultBeamWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultBeamWeapon

local CollisionBeamFile = import('defaultcollisionbeams.lua')
local DisruptorBeamCollisionBeam = CollisionBeamFile.DisruptorBeamCollisionBeam
local QuantumBeamGeneratorCollisionBeam = CollisionBeamFile.QuantumBeamGeneratorCollisionBeam
local PhasonLaserCollisionBeam = CollisionBeamFile.PhasonLaserCollisionBeam
local TractorClawCollisionBeam = CollisionBeamFile.TractorClawCollisionBeam

local EffectTemplate = import('/lua/EffectTemplates.lua')

local DefaultBuffField = import('/lua/defaultbufffield.lua').DefaultBuffField

local CreateAttachedEmitter = CreateAttachedEmitter

SeraphimBuffField = Class(DefaultBuffField) {
	AmbientEffects = '/effects/emitters/seraphim_t2_power_ambient_01_emit.bp',
    FieldVisualEmitter = '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
}

SANAnaitTorpedo = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SAnaitTorpedoMuzzleFlash,
}

SDFExperimentalPhasonProj = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SDFExperimentalPhasonProjMuzzleFlash,
    FxChargeMuzzleFlash = EffectTemplate.SDFExperimentalPhasonProjChargeMuzzleFlash,
}

SDFAireauWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SDFAireauWeaponMuzzleFlash,
}

SDFSinnuntheWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SDFSinnutheWeaponMuzzleFlash,
    FxChargeMuzzleFlash = EffectTemplate.SDFSinnutheWeaponChargeMuzzleFlash
}

SIFInainoWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SIFInainoLaunch01,
}

SIFHuAntiNukeWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SKhuAntiNukeMuzzleFlash,
}

SIFExperimentalStrategicMissile = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SIFExperimentalStrategicMissileLaunch01,
    FxChargeMuzzleFlash = EffectTemplate.SIFExperimentalStrategicMissileChargeLaunch01,
}

SDFPhasicAutoGunWeapon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.PhasicAutoGunMuzzleFlash,
}

SDFHeavyPhasicAutoGunTankWeapon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.HeavyPhasicAutoGunTankMuzzleFlash,
}

SDFHeavyPhasicAutoGunWeapon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.HeavyPhasicAutoGunMuzzleFlash,
}
    
SDFOhCannon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.OhCannonMuzzleFlash,
}

SDFOhCannon02 = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.OhCannonMuzzleFlash02,
}

SDFShriekerCannon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.ShriekerCannonMuzzleFlash,
}

-- Units: XSL0111
SIFLaanseTacticalMissileLauncher = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SLaanseMissleMuzzleFlash,
}

-- Units: XSB2303
SIFZthuthaamArtilleryCannon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash= EffectTemplate.SZthuthaamArtilleryMuzzleFlash,
	FxChargeMuzzleFlash= EffectTemplate.SZthuthaamArtilleryChargeMuzzleFlash,
}

-- Units: XSL0303
SDFThauCannon = Class(DefaultProjectileWeapon) {

	FxMuzzleFlash = EffectTemplate.STauCannonMuzzleFlash,
	FxMuzzleTerrainTypeName = 'ThauTerrainMuzzle',
	
	PlayFxMuzzleSequence = function(self, muzzle)
    
		DefaultProjectileWeapon.PlayFxMuzzleSequence(self, muzzle)
        
        local pos = self.unit:GetPosition()
        
        local TerrainType = GetTerrainType( pos.x,pos.z )
        
        local effectTable = TerrainType.FXOther[self.unit:GetCurrentLayer()][self.FxMuzzleTerrainTypeName] 
        
        if effectTable != nil then
            local army = self.unit.Sync.army
			local CreateAttachedEmitter = CreateAttachedEmitter
			
			for k, v in effectTable do
				CreateAttachedEmitter(self.unit, muzzle, army, v)
			end
		end
    end,
}

-- Units: XSL0303
SDFAireauBolterWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SAireauBolterMuzzleFlash,
}

-- Units: XSL0202
SDFAireauBolterWeapon02 = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SAireauBolterMuzzleFlash02,
}

-- Units: XSL0303
SANUallCavitationTorpedo = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SUallTorpedoMuzzleFlash
}

SANAnaitTorpedo = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SAnaitTorpedoMuzzleFlash
}

SANHeavyCavitationTorpedo = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SHeavyCavitationTorpedoMuzzleFlash
}

SANHeavyCavitationTorpedo02 = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SHeavyCavitationTorpedoMuzzleFlash02
}

SDFChronotronCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SChronotronCannonMuzzle,
    FxChargeMuzzleFlash = EffectTemplate.SChronotronCannonMuzzleCharge,
}

SDFChronotronCannonOverChargeWeapon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SChronotronCannonOverChargeMuzzle,
}

-- Units: XSL0301
SDFLightChronotronCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SLightChronotronCannonMuzzleFlash,
}

SDFLightChronotronCannonOverchargeWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SLightChronotronCannonOverChargeMuzzleFlash,
}

SAAShleoCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SShleoCannonMuzzleFlash,
}

SAAOlarisCannonWeapon = Class(DefaultProjectileWeapon) {
    FxChargeEffects = EffectTemplate.SOlarisCannonMuzzleCharge,
    FxMuzzleFlash = EffectTemplate.SOlarisCannonMuzzleFlash01,
}

SAALosaareAutoCannonWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SLosaareAutoCannonMuzzleFlash,
}
SAALosaareAutoCannonWeaponAirUnit = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SLosaareAutoCannonMuzzleFlashAirUnit,
}
SAALosaareAutoCannonWeaponSeaUnit = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SLosaareAutoCannonMuzzleFlashSeaUnit,
}


SDFAjelluAntiTorpedoDefense = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SDFAjelluAntiTorpedoLaunch01,
}

SIFThunthoCannonWeapon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SThunderStormCannonMuzzleFlash,
}

SIFSuthanusArtilleryCannon = Class(DefaultProjectileWeapon) {
	FxChargeMuzzleFlash = EffectTemplate.SRifterArtilleryChargeMuzzleFlash,
	FxMuzzleFlash = EffectTemplate.SRifterArtilleryMuzzleFlash,
}

SIFSuthanusMobileArtilleryCannon = Class(DefaultProjectileWeapon) {
	FxChargeMuzzleFlash = EffectTemplate.SRifterMobileArtilleryChargeMuzzleFlash,
	FxMuzzleFlash = EffectTemplate.SRifterMobileArtilleryMuzzleFlash,
}

SDFExperimentalPhasonLaser = Class(DefaultBeamWeapon) {
    BeamType = CollisionBeamFile.ExperimentalPhasonLaserCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.SChargeExperimentalPhasonLaser,
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
    
        if not self.ContBeamOn then
        
            local army = self.unit.Sync.army
            
            local bp = self.bp
            
			local CreateAttachedEmitter = CreateAttachedEmitter
			
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}


SDFUnstablePhasonBeam = Class(DefaultBeamWeapon) {
    BeamType = CollisionBeamFile.UnstablePhasonLaserCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {}, ####EffectTemplate.SExperimentalUnstablePhasonLaserMuzzle01,
    FxUpackingChargeEffects = EffectTemplate.CMicrowaveLaserCharge01,
    FxUpackingChargeEffectScale = 1,
}

SDFUltraChromaticBeamGenerator = Class(DefaultBeamWeapon) {
    BeamType = CollisionBeamFile.UltraChromaticBeamGeneratorCollisionBeam,
    FxMuzzleFlash = {},
    FxChargeMuzzleFlash = {},
    FxUpackingChargeEffects = EffectTemplate.SChargeUltraChromaticBeamGenerator,
    FxUpackingChargeEffectScale = 1,

    PlayFxWeaponUnpackSequence = function( self )
    
        if not self.ContBeamOn then
        
            local army = self.unit.Sync.army
            
            local bp = self.bp
            
			local CreateAttachedEmitter = CreateAttachedEmitter
			
            for k, v in self.FxUpackingChargeEffects do
                for ek, ev in bp.RackBones[self.CurrentRackSalvoNumber].MuzzleBones do
                    CreateAttachedEmitter(self.unit, ev, army, v):ScaleEmitter(self.FxUpackingChargeEffectScale)
                end
            end
            
            DefaultBeamWeapon.PlayFxWeaponUnpackSequence(self)
        end
    end,
}

SDFUltraChromaticBeamGenerator02 = Class(SDFUltraChromaticBeamGenerator) {
    BeamType = CollisionBeamFile.UltraChromaticBeamGeneratorCollisionBeam02,
}

SIFCommanderDeathWeapon = Class(BareBonesWeapon) {

    OnCreate = function(self)
    
        BareBonesWeapon.OnCreate(self)

        local myBlueprint = self.bp

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

SLaanseMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SLaanseMissleMuzzleFlash,
}

SExperimentalStrategicMissileWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SExperimentalStrategicMissileMuzzleFlash,
}

SAMElectrumMissileDefense = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SElectrumMissleDefenseMuzzleFlash,
}

SDFBombOtheWeapon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SOtheBombMuzzleFlash,
}

SIFBombZhanaseeWeapon = Class(DefaultProjectileWeapon) {
    FxMuzzleFlash = EffectTemplate.SZhanaseeMuzzleFlash01,
}

SDFHeavyQuarnonCannon = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SHeavyQuarnonCannonMuzzleFlash,
}

SDFSniperShotNormalMode = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SDFSniperShotNormalMuzzleFlash,
}

SDFSniperShotSniperMode = Class(DefaultProjectileWeapon) {
	FxMuzzleFlash = EffectTemplate.SDFSniperShotMuzzleFlash,
}

SB0OhwalliExperimentalStrategicBombWeapon = Class( DefaultProjectileWeapon) {
}

-- ALL OF THIS COMES FROM BrewLAN --

SDFGapingMaw = Class(DefaultBeamWeapon) {
    BeamType = TractorClawCollisionBeam,
    FxMuzzleFlash = {},

    PlayFxBeamStart = function(self, muzzle)
    
        local target = self:GetCurrentTarget()
        
        local bp = self.bp
        
        if not target or not EntityCategoryContains(categories.ALLUNITS - categories.STRUCTURE, target) then
            -- Since this is now survivable, and has a fixed size max I don't feel bad about allowing:
            -- - categories.SUBCOMMANDER - categories.COMMAND - categories.EXPERIMENTAL
            return
        else
            local max = bp.MaxEdibleSize or {3, 5, 3}
            local targetbp = target:GetBlueprint()
            if targetbp.SizeX > max[1] or targetbp.SizeZ > max[2] or targetbp.SizeY > max[3] then
                --LOG(targetbp.Description .. " is too big to eat")
                return
            end
        end

        --Can't pass recon blips down
        target = self:GetRealTarget(target)

        DefaultBeamWeapon.PlayFxBeamStart(self, muzzle)

        self.TT1 = self:ForkThread(self.TractorThread, target)
        self:ForkThread(self.TractorWatchThread, target, bp.MandibleMaxHoldTimeTicks or 20)
    end,

    --recon blip check
    GetRealTarget = function(self, target)
    
        if target and not IsUnit(target) then
        
            local unitTarget = target:GetSource()
            local unitPos = unitTarget:GetPosition()
            local reconPos = target:GetPosition()
            local dist = VDist2(unitPos[1], unitPos[3], reconPos[1], reconPos[3])
            
            if dist < 10 then
                return unitTarget
            end
            
        end
        
        return target
    end,

    OnLostTarget = function(self)
    
        self:AimManipulatorSetEnabled(true)
        DefaultBeamWeapon.OnLostTarget(self)
        
        ------enabled= false
        ------self.unit:SetEnabled(false)
        
        DefaultBeamWeapon.PlayFxBeamEnd(self,self.Beams[1].Beam)
    end,

    TractorThread = function(self, target)
        local beam = self.Beams[1].Beam
        if not beam then return end

        local bp = self.bp
        
        local muzzle = bp.MuzzleSpecial
        if not muzzle then return end

        target:SetDoNotTarget(true)
        
        local pos0 = beam:GetPosition(0)
        local pos1 = beam:GetPosition(1)
        local dist = VDist3(pos0, pos1)
                    --CreateSlider(unit,      bone, [goal_x, goal_y, goal_z, [speed,
        self.Slider = CreateSlider(self.unit, muzzle, 0, 0, dist, -1, true)
        if not self.Animator and bp.AnimationAttack and bp.AnimationEat then
            self.Animator = CreateAnimator(self.unit)
            self.NomAnimator = CreateAnimator(self.unit)
            self.unit.Trash:Add(self.Animator)
            self.unit.Trash:Add(self.NomAnimator)
        end
        self.Animator:PlayAnim(bp.AnimationAttack, false):SetRate(1.5)
        coroutine.yield(1)
        WaitFor(self.Slider)
        WaitFor(self.Animator)

        -- just in case attach fails...
        target:SetDoNotTarget(false)
        target:AttachBoneTo(-1, self.unit, muzzle)
        target:SetDoNotTarget(true)

        self.NomAnimator:PlayAnim(bp.AnimationEat, true):SetRate(1)
        self.AimControl:SetResetPoseTime(2)

        self.Slider:SetSpeed(30)
        self.Slider:SetGoal(0,0,0)
        self.Animator:SetRate(-1)

        coroutine.yield(1)
        WaitFor(self.Slider)
        WaitFor(self.Animator)

        if not target.Dead then
            while target:GetHealth() > (bp.MandibleDamage or 700) do
                Damage(self.unit, self.unit:GetPosition(muzzle), target, (bp.MandibleDamage or 700), bp.DamageType)
                coroutine.yield(math.max((bp.MandibleDamageInterval or 1),1))
            end
            if target:GetHealth() < (bp.MandibleDamage or 700) then
                if target.DestructionExplosionWaitDelayMin and target.DestructionExplosionWaitDelayMax then
                    target.DestructionExplosionWaitDelayMin = 0
                    target.DestructionExplosionWaitDelayMax = 0
                end
                target:Kill(self.unit, 'Damage', bp.MandibleDamage)
                target:HideBone(0, true)
            end
            for kEffect, vEffect in EffectTemplate.ACollossusTractorBeamCrush01 do
                CreateEmitterAtBone( self.unit, muzzle , self.unit:GetArmy(), vEffect )------:ScaleEmitter(0.35)
            end
        end

        self.AimControl:SetResetPoseTime(2)
    end,

    TractorWatchThread = function(self, target, yeetcount)
    
        while (not target:IsDead() or not self.unit.Dead) and yeetcount > 0 do
            coroutine.yield(1)
            yeetcount = yeetcount - 1
        end
        
        KillThread(self.TT1)
        
        self.TT1 = nil
        
        if self.Slider then
            self.Slider:Destroy()
            self.Slider = nil
        end
        
        self.unit:DetachAll(self:GetBlueprint().MuzzleSpecial or 0)
        self:ResetTarget()
        self.AimControl:SetResetPoseTime(2)
        
        local animfrac = self.NomAnimator:GetAnimationFraction()
        
        if animfrac ~= 1 and animfrac ~= 0 then
        
            coroutine.yield( self.NomAnimator:GetAnimationDuration() / self.NomAnimator:GetRate() * (1 - animfrac) * 10 )
            
        end
        
        self.NomAnimator:SetAnimationFraction(0)
        self.NomAnimator:SetRate(0)
        
        if self.unit and not self.unit.Dead and target and not yeetcount > 0 then
            target:Destroy() -- This prevents potentially verbose death thread stuff.
        elseif target and not target.Dead then
            target:SetDoNotTarget(false)
        end
    end,
}

InvisibleCollisionBeam = Class(moho.CollisionBeamEntity) {

    OnCreate = function(self)
        self.Trash = TrashBag()
    end,

    OnDestroy = function(self)
        if self.Trash then
            self.Trash:Destroy()
        end
    end,

    OnEnable = function(self)
    end,

    OnDisable = function(self)
    end,

    SetParentWeapon = function(self, weapon)
        self.Weapon = weapon
    end,

    DoDamage = function(self, instigator, damageData, targetEntity)
    
        local damage = damageData.DamageAmount or 0
        local dmgmod = 1
        
        if self.Weapon.DamageModifiers then
            for k, v in self.Weapon.DamageModifiers do
                dmgmod = v * dmgmod
            end
        end
        
        damage = damage * dmgmod
        
        if instigator and damage > 0 then
        
            local radius = damageData.DamageRadius
            
            if radius and radius > 0 then
            
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    DamageArea(instigator, self:GetPosition(1), radius, damage, damageData.DamageType or 'Normal', damageData.DamageFriendly or false)
                else
                    ForkThread(DefaultDamage.AreaDoTThread, instigator, self:GetPosition(1), damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), radius, damage, damageData.DamageType, damageData.DamageFriendly)
                end
                
            elseif targetEntity then
            
                if not damageData.DoTTime or damageData.DoTTime <= 0 then
                    Damage(instigator, self:GetPosition(), targetEntity, damage, damageData.DamageType)
                else
                    ForkThread(DefaultDamage.UnitDoTThread, instigator, targetEntity, damageData.DoTPulses or 1, (damageData.DoTTime / (damageData.DoTPulses or 1)), damage, damageData.DamageType, damageData.DamageFriendly)
                end
                
            else
            
                DamageArea(instigator, self:GetPosition(1), 0.25, damage, damageData.DamageType, damageData.DamageFriendly)
            end
        else
            LOG('*ERROR: THERE IS NO INSTIGATOR FOR DAMAGE ON THIS COLLISIONBEAM = ', repr(damageData))
        end
    end,

    -- This is called when the collision beam hits something new. Because the beam
    -- is continuously detecting collisions it only executes this function when the
    -- thing it is touching changes. Expect Impacts with non-physical things like
    -- 'Air' (hitting nothing) and 'Underwater' (hitting nothing underwater).
    OnImpact = function(self, impactType, targetEntity)
        --LOG('*DEBUG: COLLISION BEAM ONIMPACT ', repr(self))
        --LOG('*DEBUG: COLLISION BEAM ONIMPACT, WEAPON =  ', repr(self.Weapon), 'Type = ', impactType)
        --LOG('CollisionBeam impacted with: ' .. impactType )
        -- Possible 'type' values are:
        --  'Unit'
        --  'Terrain'
        --  'Water'
        --  'Air'
        --  'UnitAir'
        --  'Underwater'
        --  'UnitUnderwater'
        --  'Projectile'
        --  'Prop'
        --  'Shield'

        local instigator = self:GetLauncher()
        
        if not self.DamageData then
            self:SetDamageTable()
        end

        -- Do Damage
        if targetEntity and IsUnit(targetEntity) then
            --LOG(" damagee?")
            local tentID = targetEntity:GetEntityId()
            if self.Weapon[self.DamageTracker] and not self.Weapon[self.DamageTracker][tentID] then
                -- Buffs (Stun, etc)
                self:DoUnitImpactBuffs(targetEntity)

                local damageData = self.DamageData

                self.Weapon[self.DamageTracker][tentID] = true
                self:DoDamage( instigator, damageData, targetEntity)
            --else
            --    LOG("target ".. tentID .." hit multiple times")
            end
        end

    end,

    GetCollideFriendly = function(self)
        return self.DamageData.CollideFriendly
    end,

    SetDamageTable = function(self)
    
        local weaponBlueprint = self.Weapon:GetBlueprint()
        
        self.DamageData = {}
        self.DamageData.DamageRadius = weaponBlueprint.DamageRadius
        self.DamageData.DamageAmount = weaponBlueprint.Damage
        self.DamageData.DamageType = weaponBlueprint.DamageType
        self.DamageData.DamageFriendly = weaponBlueprint.DamageFriendly
        self.DamageData.CollideFriendly = weaponBlueprint.CollideFriendly
        self.DamageData.DoTTime = weaponBlueprint.DoTTime
        self.DamageData.DoTPulses = weaponBlueprint.DoTPulses
        self.DamageData.Buffs = weaponBlueprint.Buffs
    end,

    --When this beam impacts with the target, do any buffs that have been passed to it.
    DoUnitImpactBuffs = function(self, target)
    
        local data = self.DamageData
        
        if data.Buffs then
            for k, v in data.Buffs do
                if v.Add.OnImpact == true and not EntityCategoryContains((ParseEntityCategory(v.TargetDisallow) or ''), target)
                    and EntityCategoryContains((ParseEntityCategory(v.TargetAllow) or categories.ALLUNITS), target) then

                    target:AddBuff(v)
                end
            end
        end
    end,

    ForkThread = function(self, fn, ...)
        if fn then
            local thread = ForkThread(fn, self, unpack(arg))
            self.Trash:Add(thread)
            return thread
        else
            return nil
        end
    end,
}

local Weapon = import('/lua/sim/Weapon.lua').Weapon

SMeleeBladeBeamWeapon = Class(Weapon) {
    --Test beam. Doesn't have the custom collision stuff, so just for visual checking.
    --BeamType = Class(import('/lua/sim/CollisionBeam.lua').CollisionBeam){FxBeam = import('/lua/EffectTemplates.lua').TDFHiroGeneratorBeam},
    BeamType = InvisibleCollisionBeam,

    OnCreate = function(self)
    
        self.Beams = {}
        
        local bp = self.bp
        local counter = 0
        
        for i, blade in bp.Blades do
        
            for j, muzzle in blade.MuzzleBones do
            
                local beam
                
                beam = self.BeamType{
                    Weapon = self,
                    BeamBone = 0,
                    OtherBone = muzzle,
                    CollisionCheckInterval = 1,
                }
                
                self.Beams[counter] = { Beam = beam, Muzzle = muzzle }
                counter = counter + 1
                
                self.unit.Trash:Add(beam)
                
                beam.DamageTracker = 'DamageTracker'..i
                
                beam:SetParentWeapon(self)
                beam:Disable()
            end
        end
        
        BareBonesWeapon.OnCreate(self)
    end,

    OnFire = function(self)
        --Set up
        if not self.Blades then
            self.Blades = self:GetBlueprint().Blades
        end
        
        if self.NoAttackChance and self.NoAttackChance >= math.random(1,4) then
            --This allows it to still attack with both, but makes it less likely.
            return
        end
        
        --Pick which limb or set of limbs we're doing
        local bn = math.random(1, table.getn(self.Blades))
        
        --If that limb is busy, try again later.
        local bncheck = 'Is'..bn..'Swinging'
        
        if self[bncheck] then
            return
        end

        --Set up
        local blade = self.Blades[bn]
        local bnanim = 'Animator' .. bn
        
        if not self[bnanim] then
            self[bnanim] = CreateAnimator(self.unit)
            self.unit.Trash:Add(self[bnanim])
        end
        
        -- no point checking if anything is in it, it needs resetting, and it'll only be empty if we missed
        self['DamageTracker'..bn] = {}
        
        --Start swinging
        self[bncheck] = true
        self.NoAttackChance = 3
        self[bnanim]:PlayAnim(blade.Animations[math.random(1, table.getn(blade.Animations))]):SetRate(0.65 + math.random()/5)
        
        --Disable walk and idle anims on the main limb(s)
        local SetOtherAnimatorsActive = function(self, blade, active)
            for i, bone in blade.LimbBones do
                for i, animator in {self.unit.Animator, self.unit.IdleAnimator, self.unit.TallStanceAnimator} do
                    if animator then
                        animator:SetBoneEnabled(bone, active, true)
                    end
                end
            end
        end
        
        SetOtherAnimatorsActive(self, blade, false)
        
        self:ForkThread(function()
            local AFF = {0.35,0.65}
            local totalAnimLength = self[bnanim]:GetAnimationDuration()/math.abs(self[bnanim]:GetRate()) * 10
            
            --Wait unti blade is swinging
            coroutine.yield(totalAnimLength * AFF[1])
            self.NoAttackChance = 2
            
            --Enable collision beams
            for i, muzzle in blade.MuzzleBones do
                self:PlayFxBeamStart(muzzle)
            end
            
            --Wait until blade has finished swinging
            coroutine.yield(totalAnimLength * (AFF[2] - AFF[1]))
            self.NoAttackChance = 1
            self:PlayFxBeamEnd()
            
            --Wait until the reset portion of the animation is complete
            coroutine.yield(totalAnimLength * (1 - AFF[2]))
            self.NoAttackChance = 0
            self[bncheck] = nil
            SetOtherAnimatorsActive(self, blade, true)
        end)
    end,

    PlayFxBeamStart = function(self, muzzle)
    
        local army = self.unit.Sync.army
        local bp = self.bp
        
        local beam
        local beamTable
        
        for k, v in self.Beams do
            if v.Muzzle == muzzle then
                beam = v.Beam
                beamTable = v
            end
        end
        
        if not beam then
            error('*ERROR: We have a beam created that does not coincide with a muzzle bone.  Internal Error, aborting beam weapon.', 2)
            return
        end
        
        if beam:IsEnabled() then return end
        
        beam:Enable()
        
        self.HoldFireThread = self:ForkThread(self.WatchForHoldFire, beam)
        self.BeamStarted = true
    end,

    PlayFxBeamEnd = function(self, beam)
    
        if not self.unit.Dead then
        
            local bp = self.bp
            
            if beam then
                beam:Disable()
            else
                for k, v in self.Beams do
                    v.Beam:Disable()
                end
            end
            
            self.BeamStarted = false
        end
        
        if self.HoldFireThread then
            KillThread(self.HoldFireThread)
        end
    end,

    ContinuousBeamFlagThread = function(self)
        coroutine.yield(1)
        self.ContBeamOn = false
    end,

    WatchForHoldFire = function(self, beam)
        while true do
            coroutine.yield(11)
            --if we're at hold fire, stop beam
            if self.unit and self.unit:GetFireState() == 1 then
                self.BeamStarted = false
                self:PlayFxBeamEnd(beam)
            end
        end
    end,

    OnHaltFire = function(self)
        for k, v in self.Beams do
            -- Only halt fire on the beams that are currently enabled
            if not v.Beam:IsEnabled() then
                continue
            end
            self:PlayFxBeamEnd( v.Beam )
        end
    end,
}

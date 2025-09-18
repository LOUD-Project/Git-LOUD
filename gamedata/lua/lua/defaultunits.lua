--   /lua/defaultunits.lua
-- Summary  :  Default definitions of units

-- This file describes the first layer down from the UNIT entity
-- covering basic concepts like -- DUMMY Units, STRUCTURE Units, MOBILE Units and
-- then most of their sub-classes
local EntityOnCreate    = import('/lua/sim/Entity.lua').Entity.OnCreate

local Unit      = import('/lua/sim/unit.lua').Unit

local GetRandomOffset                   = Unit.GetRandomOffset

local UnitOnCreate                      = Unit.OnCreate
local UnitOnHealthChanged               = Unit.OnHealthChanged
local UnitOnPreCreate                   = Unit.OnPreCreate
local UnitOnScriptBitSet                = Unit.OnScriptBitSet
local UnitOnStartBuild                  = Unit.OnStartBuild
local UnitOnStopBeingBuilt              = Unit.OnStopBeingBuilt
local UnitOnStopBuild                   = Unit.OnStopBuild
local UnitOnTransportAttach             = Unit.OnTransportAttach
local UnitOnTransportDetach             = Unit.OnTransportDetach
local UnitOnLayerChange                 = Unit.OnLayerChange
local UnitOnKilled                      = Unit.OnKilled
local PlayUnitSound                     = Unit.PlayUnitSound
local UnitStartBeingBuiltEffects        = Unit.StartBeingBuiltEffects
local UnitStopBeingBuiltEffects         = Unit.StopBeingBuiltEffects

local DefaultExplosions = import('defaultexplosions.lua')

local CreateDebrisProjectiles               = DefaultExplosions.CreateDebrisProjectiles
local CreateDefaultHitExplosion             = DefaultExplosions.CreateDefaultHitExplosion
local CreateDefaultHitExplosionAtBone       = DefaultExplosions.CreateDefaultHitExplosionAtBone
local CreateScalableUnitExplosion           = DefaultExplosions.CreateScalableUnitExplosion
local CreateTimedStuctureUnitExplosion      = DefaultExplosions.CreateTimedStuctureUnitExplosion
local CreateUnitExplosionEntity             = DefaultExplosions.CreateUnitExplosionEntity
local GetAverageBoundingXZRadius            = DefaultExplosions.GetAverageBoundingXZRadius
local GetAverageBoundingXYZRadius           = DefaultExplosions.GetAverageBoundingXYZRadius

DefaultExplosions = nil

local EffectTemplate = import('/lua/EffectTemplates.lua')

local EffectUtilities = import('/lua/EffectUtilities.lua')

local CleanupEffectBag                  = EffectUtilities.CleanupEffectBag
local CreateAdjacencyBeams              = EffectUtilities.CreateAdjacencyBeams
local CreateAeonBuildBaseThread         = EffectUtilities.CreateAeonBuildBaseThread
local CreateBoneEffects                 = EffectUtilities.CreateBoneEffects
local CreateBuildCubeThread             = EffectUtilities.CreateBuildCubeThread
local CreateEffects                     = EffectUtilities.CreateEffects
local CreateSeraphimBuildBaseThread     = EffectUtilities.CreateSeraphimBuildBaseThread
local CreateUEFUnitBeingBuiltEffects    = EffectUtilities.CreateUEFUnitBeingBuiltEffects
local PlayCaptureEffects                = EffectUtilities.PlayCaptureEffects
local PlayReclaimEffects                = EffectUtilities.PlayReclaimEffects
local PlayReclaimEndEffects             = EffectUtilities.PlayReclaimEndEffects
local PlaySacrificeEffects              = EffectUtilities.PlaySacrificeEffects
local PlaySacrificingEffects            = EffectUtilities.PlaySacrificingEffects

EffectUtilities = nil

local GetMarkers    = import('/lua/sim/scenarioutilities.lua').GetMarkers

local ApplyBuff     = import('/lua/sim/buff.lua').ApplyBuff
local HasBuff       = import('/lua/sim/buff.lua').HasBuff
local RemoveBuff    = import('/lua/sim/buff.lua').RemoveBuff

local AssignTransportToPool     = import('/lua/ai/transportutilities.lua').AssignTransportToPool
local ProcessAirUnits           = import('/lua/loudutilities.lua').ProcessAirUnits
local ReturnTransportsToPool    = import('/lua/ai/transportutilities.lua').ReturnTransportsToPool

local LOUDCOPY  = table.copy
local LOUDCEIL  = math.ceil
local LOUDFIND  = string.find
local LOUDFLOOR = math.floor
local LOUDGETN  = table.getn
local LOUDINSERT = table.insert
local LOUDSUB   = string.sub

local ChangeState           = ChangeState
local CreateDecal           = CreateDecal
local CreateAnimator        = CreateAnimator
local CreateAttachedEmitter = CreateAttachedEmitter
local CreateEmitterAtEntity = CreateEmitterAtEntity
local CreateEmitterAtBone   = CreateEmitterAtBone
local EntityCategoryContains = EntityCategoryContains
local ForkThread            = ForkThread
local ForkTo                = ForkThread
local KillThread            = KillThread
local LOUDATTACHBEAMENTITY  = AttachBeamEntityToEntity
local Random                = Random

local TrashBag      = TrashBag
local TrashAdd      = TrashBag.Add
local TrashDestroy  = TrashBag.Destroy

local VDist2    = VDist2
local VDist2Sq  = VDist2Sq
local VDist3    = VDist3
local WaitTicks = coroutine.yield

local AssignUnitsToPlatoon  = moho.aibrain_methods.AssignUnitsToPlatoon
local MakePlatoon           = moho.aibrain_methods.MakePlatoon

local BeenDestroyed         = moho.entity_methods.BeenDestroyed
local DisableIntel          = moho.entity_methods.DisableIntel
local EnableIntel           = moho.entity_methods.EnableIntel
local GetBoneCount          = moho.entity_methods.GetBoneCount
local GetFractionComplete   = moho.entity_methods.GetFractionComplete
local GetPosition           = moho.entity_methods.GetPosition

local GetAIBrain                    = moho.unit_methods.GetAIBrain
local GetWeapon                     = moho.unit_methods.GetWeapon
local GetWeaponCount                = moho.unit_methods.GetWeaponCount
local HideBone                      = moho.unit_methods.HideBone
local IsBeingBuilt                  = moho.unit_methods.IsBeingBuilt
local SetConsumptionPerSecondMass   = moho.unit_methods.SetConsumptionPerSecondMass
local SetProductionActive           = moho.unit_methods.SetProductionActive
local SetProductionPerSecondMass    = moho.unit_methods.SetProductionPerSecondMass

local PlayAnim = moho.AnimationManipulator.PlayAnim

local VectorCached = { 0, 0, 0 }

local AIRUNITS          = (categories.AIR * categories.MOBILE) - categories.INSIGNIFICANTUNIT
local FACTORIES         = categories.FACTORY - categories.EXPERIMENTAL
local ENERGYPRODUCTION  = categories.ENERGYPRODUCTION - categories.HYDROCARBON - categories.EXPERIMENTAL - categories.TECH1
local MASSPRODUCTION    = categories.MASSPRODUCTION - categories.EXPERIMENTAL
local INTEL             = categories.INTELLIGENCE - categories.OPTICS
local SERAPHIMAIR       = categories.SERAPHIM * categories.AIR
local TRANSPORTS        = categories.TRANSPORTFOCUS - categories.uea0203

local function GetRandomFloat( Min, Max )
    return Min + (Random() * (Max-Min) )
end

local function GetRandomInt( nmin, nmax)
    return LOUDFLOOR(Random() * (nmax - nmin + 1) + nmin)
end

DummyUnit = Class(Unit) {

    OnStopBeingBuilt = function(self,builder,layer)
        self:Destroy()
    end,
}

StructureUnit = Class(Unit) {

    LandBuiltHiddenBones = {'Floatation'},

    -- Stucture unit specific damage effects and smoke
    FxDamage1 = { EffectTemplate.DamageStructureSmoke01, EffectTemplate.DamageStructureSparks01 },
    FxDamage2 = { EffectTemplate.DamageStructureFireSmoke01, EffectTemplate.DamageStructureSparks01 },
    FxDamage3 = { EffectTemplate.DamageStructureFire01, EffectTemplate.DamageStructureSparks01 },

    IdleState = State {
        Main = function(self)
            self.UnitBeingBuilt = nil
        end,
    },

    UpgradingState = State {

        Main = function(self)

            self:DestroyTarmac()

            PlayUnitSound(self,'UpgradeStart')

            self:DisableDefaultToggleCaps()

            local bp = __blueprints[self.BlueprintID].Display

            if bp.AnimationUpgrade then

                local unitBuilding = self.UnitBeingBuilt
                
                local FractionComplete = GetFractionComplete( unitBuilding )

                self.AnimatorUpgradeManip = CreateAnimator(self)

                TrashAdd( self.Trash, self.AnimatorUpgradeManip )

                self:StartUpgradeEffects(unitBuilding)

                PlayAnim( self.AnimatorUpgradeManip, bp.AnimationUpgrade, false):SetRate(0)

                while FractionComplete < 1 and not self.Dead do

                    WaitTicks(4)
                    
                    if not unitBuilding.Dead then

                        FractionComplete = GetFractionComplete( unitBuilding )

                    else
                    
                        FractionComplete = 1

                    end
                    
                    if not self.Dead then

                        self.AnimatorUpgradeManip:SetAnimationFraction( FractionComplete )
                    
                    end

                end

                if not self.Dead then
                    self.AnimatorUpgradeManip:SetRate(1)
                end

            end

        end,

        OnStopBuild = function(self, unitBuilding)

            UnitOnStopBuild(self, unitBuilding)

            self:EnableDefaultToggleCaps()

            if GetFractionComplete(unitBuilding) == 1 then

                NotifyUpgrade(self, unitBuilding)

                self:StopUpgradeEffects(unitBuilding)

                PlayUnitSound(self,'UpgradeEnd')

				self:DoDestroyCallbacks()

                self:Destroy()

            end

        end,

        OnFailedToBuild = function(self)

            Unit.OnFailedToBuild(self)

            self:EnableDefaultToggleCaps()

            if self.AnimatorUpgradeManip then

				self.AnimatorUpgradeManip:Destroy()

				self.AnimatorUpgradeManip = nil

			end

            PlayUnitSound(self,'UpgradeFailed')

            self:PlayActiveAnimation()

            self:CreateTarmac(true, true, true, false, self.TarmacBag.CurrentBP)

            ChangeState(self, self.IdleState)

        end,
    },

    OnCreate = function(self)

        UnitOnCreate(self)

		-- ALL STRUCTURES now cache their position - as it never changes
		self.CachePosition = LOUDCOPY(GetPosition(self))

        if self.CacheLayer == 'Land' then
        
            local bp = __blueprints[self.BlueprintID]

			if bp.Physics.FlattenSkirt then
				self:FlattenSkirt(bp)
			end
        end

    end,

	-- since Structures dont move we'll override the GetPosition function and use
	-- the cacheposition we stored above
	GetPosition = function(self)
		return self.CachePosition
	end,
	
	GetCachePosition = function(self)
		return self.CachePosition
	end,

    OnFailedToBeBuilt = function(self)

        Unit.OnFailedToBeBuilt(self)

        self:DestroyTarmac()

    end,

    FlattenSkirt = function( self, bp )

        local x0,z0,x1,z1 = self:GetSkirtRect( bp )

        x0,z0,x1,z1 = LOUDFLOOR(x0),LOUDFLOOR(z0),LOUDCEIL(x1),LOUDCEIL(z1)

        FlattenMapRect(x0, z0, x1-x0, z1-z0, GetPosition(self)[2])

    end,

    CreateEnhancement = function(self, enh)

        local bp = __blueprints[self.BlueprintID]
		local bpE = bp.Enhancements[enh]

        if not bpE then return end

        Unit.CreateEnhancement(self, enh)

        if enh == 'ImprovedProduction' then

            ApplyBuff(self,'FACTORY_30_BuildRate')
			ApplyBuff(self,'VeterancyRegen4')
			self:SetCustomName("T3 Fac +30%")

        elseif enh == 'ImprovedProductionRemove' then

            if HasBuff( self,'FACTORY_30_BuildRate' ) then
                RemoveBuff( self,'FACTORY_30_BuildRate' )
				self:SetCustomName("")
            end

        elseif enh == 'AdvancedProduction' then

            ApplyBuff(self,'FACTORY_60_BuildRate')
			ApplyBuff(self,'VeterancyRegen5')
			self:SetCustomName("T3 Fac +60%")

        elseif enh == 'AdvancedProductionRemove' then

            if HasBuff( self,'FACTORY_60_BuildRate' ) then
                RemoveBuff( self,'FACTORY_60_BuildRate' )
				self:SetCustomName("")
            end

		elseif enh == 'ImprovedMateriels' then

			ApplyBuff(self,'FACTORY_10_Materiel')
			ApplyBuff( self,'VeterancyHealth2')
			self:SetCustomName("T3 Fac +10% Materiels")

		elseif enh == 'ImprovedMaterielsRemove' then

            if HasBuff( self,'FACTORY_10_Materiel' ) then
                RemoveBuff( self,'FACTORY_10_Materiel' )
				RemoveBuff( self,'VeterancyHealth2')
            end

		elseif enh == 'AdvancedMateriels' then

			ApplyBuff(self,'FACTORY_20_Materiel')
			ApplyBuff(self,'VeterancyHealth4')
			self:SetCustomName("T3 Fac +20% Materiels")

		elseif enh == 'AdvancedMaterielsRemove' then

            if HasBuff( self,'FACTORY_20_Materiel' ) then
                RemoveBuff( self,'FACTORY_20_Materiel' )
				RemoveBuff( self,'VeterancyHealth4')
            end
            if HasBuff( self,'FACTORY_10_Materiel' ) then
                RemoveBuff( self,'FACTORY_10_Materiel' )
				RemoveBuff( self,'VeterancyHealth2')
            end

		elseif enh == 'ExperimentalMateriels' then

			ApplyBuff(self,'FACTORY_25_Materiel')
			ApplyBuff(self,'VeterancyHealth5')
			self:SetCustomName("T3 Fac +25% Materiels")

		elseif enh == 'ExperimentalMaterielsRemove' then

            if HasBuff( self,'FACTORY_25_Materiel' ) then
                RemoveBuff( self,'FACTORY_25_Materiel' )
				RemoveBuff( self,'VeterancyHealth5')
            end
            if HasBuff( self,'FACTORY_20_Materiel' ) then
                RemoveBuff( self,'FACTORY_20_Materiel' )
				RemoveBuff( self,'VeterancyHealth4')
            end
            if HasBuff( self,'FACTORY_10_Materiel' ) then
                RemoveBuff( self,'FACTORY_10_Materiel' )
				RemoveBuff( self,'VeterancyHealth2')
            end

		elseif enh == 'InstallT2Radar' then

			self:SetupIntel(bp)

			self:AddToggleCap('RULEUTC_IntelToggle')
			ApplyBuff(self, 'INSTALL_T2_Radar')
			self:SetCustomName("T2 Radar")

			self:SetEnergyMaintenanceConsumptionOverride(bpE.MaintenanceConsumptionPerSecondEnergy or 0)
			self:SetMaintenanceConsumptionActive()

		elseif enh == 'InstallT3Radar' then

			self:SetupIntel(bp)

			self:AddToggleCap('RULEUTC_IntelToggle')
			ApplyBuff(self, 'INSTALL_T3_Radar')

			self:SetEnergyMaintenanceConsumptionOverride(bpE.MaintenanceConsumptionPerSecondEnergy or 0)
			self:SetMaintenanceConsumptionActive()

		elseif enh == 'InstallT3RadarRemove' then

			self:SetMaintenanceConsumptionInactive()

			self:RemoveToggleCap('RULEUTC_IntelToggle')
			RemoveBuff( self,'INSTALL_T3_Radar')

		elseif enh == 'InstallT2Sonar' then

			self:SetupIntel(bp)

			self:AddToggleCap('RULEUTC_IntelToggle')
			ApplyBuff(self, 'INSTALL_T2_Sonar')
			self:SetCustomName("T2 Sonar")

			self:SetEnergyMaintenanceConsumptionOverride(bpE.MaintenanceConsumptionPerSecondEnergy or 0)
			self:SetMaintenanceConsumptionActive()

		elseif enh == 'InstallT3Sonar' then

			self:SetupIntel(bp)

			self:AddToggleCap('RULEUTC_IntelToggle')
			ApplyBuff(self, 'INSTALL_T3_Sonar')

			self:SetEnergyMaintenanceConsumptionOverride(bpE.MaintenanceConsumptionPerSecondEnergy or 0)
			self:SetMaintenanceConsumptionActive()

		elseif enh == 'InstallT3SonarRemove' then

			self:SetMaintenanceConsumptionInactive()

			self:RemoveToggleCap('RULEUTC_IntelToggle')
			RemoveBuff( self,'INSTALL_T3_Sonar')

	    elseif enh == 'InstallFactoryShield' then

            self:AddToggleCap('RULEUTC_ShieldToggle')

			if bpE.PersonalShield then
				self:CreatePersonalShield(bpE)
			else
			    self:CreateShield(bpE)
			end

            self:SetEnergyMaintenanceConsumptionOverride(bpE.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()

		elseif enh == 'InstallFactoryShieldRemove' then

			self:RemoveToggleCap('RULEUTC_ShieldToggle')

			self:SetMaintenanceConsumptionInactive()

			self:DisableShield()
			self.MyShield:RemoveShield()

		elseif enh == 'InstallRegenPackage1' then

			ApplyBuff( self, 'RegenPackage1' )

		elseif enh == 'InstallRegenPackage2' then

			ApplyBuff( self, 'RegenPackage2' )

		elseif enh == 'InstallArmorPackage1' then

			ApplyBuff( self, 'ArmorPackage1' )

		end

	end,

    CreateTarmac = function(self, albedo, normal, glow, orientation, specTarmac, lifeTime)

        if self.CacheLayer != 'Land' then return end

        local orient,tarmac

        local bp = __blueprints[self.BlueprintID].Display.Tarmacs

        if not specTarmac then
		
            if bp[1] then
                tarmac = bp[Random(1, LOUDGETN(bp))]
            else
                return false
            end
        else
            tarmac = specTarmac
        end

        orient = orientation

        if not orientation then
		
            if tarmac.Orientations[1] then
			
                orient = tarmac.Orientations[Random(1, LOUDGETN(tarmac.Orientations))]
                orient = (0.01745 * orient)
				
				tarmac.Orientations = nil
            else
                orient = 0
            end
        end
        
        if lifeTime then
            tarmac.LifeTime = lifeTime
        end
        
        if not tarmac.RemoveWhenDead then
            tarmac.RemoveWhenDead = true
        end
        
        if tarmac.DeathLifetime then
            tarmac.DeathLifetime = math.min( 45, tarmac.DeathLifetime )
        end
        
        tarmac.DeathLifetime = nil
        tarmac.RemoveWhenDead = nil
        
        --LOG("*AI DEBUG Creating tarmac "..repr(tarmac))

		local CreateDecal   = CreateDecal
		local LOUDGETN      = LOUDGETN		
		local LOUDINSERT    = LOUDINSERT
		local Random        = Random
        local TrashAdd      = TrashAdd

        local army      = self.Army
        local fadeout   = tarmac.FadeOut or 160     -- LOD level
        local lifeTime  = tarmac.Lifetime or 480    -- time to last in seconds (8 minutes)
        local l         = tarmac.Length             -- physical length and width
        local w         = tarmac.Width

		local pos = GetPosition(self)
		
		local x = pos[1]
		local y = pos[2]
		local z = pos[3]

        local GetTarmac = import('/lua/tarmacs.lua').GetTarmacType

        local terrain = GetTerrainType(x, z)
        local terrainName
		
        if terrain then
            terrainName = terrain.Name
        end

        local factionTable  = {e=1, a=2, r=3, s=4}
        local faction       = factionTable[ LOUDSUB(self.BlueprintID,2,2)]
        local tarmacdec     = GetTarmac(faction, terrainName)
        local tarmacHndl    = false

        if albedo and tarmac.Albedo then
		
            local albedo2 = tarmac.Albedo2
			
            if albedo2 then
                albedo2 = albedo2..tarmacdec
            end

            tarmacHndl = CreateDecal( pos, orient, tarmac.Albedo..tarmacdec, albedo2 or '', 'Albedo', w, l, fadeout, lifeTime, army, 0)
        end

        if normal and tarmac.Normal then
            tarmacHndl = CreateDecal( pos, orient, tarmac.Normal..tarmacdec, '', 'Alpha Normals', w, l, fadeout, lifeTime, army, 0)
        end

        if glow and tarmac.Glow then
            tarmacHndl = CreateDecal( pos, orient, tarmac.Glow..tarmacdec, '', 'Glow', w, l, fadeout, lifeTime, army, 0)
        end

        if tarmacHndl then

			if not self.TarmacBag then
				self.TarmacBag = { Decals = {}, CurrentBP = tarmac }
			end

            LOUDINSERT(self.TarmacBag.Decals, tarmacHndl)
            
            self.Trash:Add(tarmacHndl)

        end

    end,

    DestroyTarmac = function(self)

        if self.TarmacBag then

			for k, v in self.TarmacBag.Decals do
				v:Destroy()
                self.TarmacBag.Decals[k] = nil
			end

			self.TarmacBag.Orientation = nil
			self.TarmacBag.CurrentBP = nil
			self.TarmacBag.Decals = nil
			
			self.TarmacBag = nil
		end
		
    end,

    HasTarmac = function(self)

        if self.TarmacBag then
		
			return true
			
		end
		
		return false
    end,

    CreateDestructionEffects = function( self, overKillRatio )

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." CreateDestructionEffects on overkill "..overKillRatio.." on tick "..GetGameTick())
        end

        if ( GetAverageBoundingXZRadius( self ) < 1.0 ) then
            CreateScalableUnitExplosion( self, overKillRatio )
        else
            CreateTimedStuctureUnitExplosion( self )
            WaitTicks(4)
            CreateScalableUnitExplosion( self, overKillRatio )
        end
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )

        UnitOnStartBuild(self,unitBeingBuilt, order)
        
		self.UnitBeingBuilt = unitBeingBuilt

		if order == 'Upgrade' then

			if unitBeingBuilt.BlueprintID == __blueprints[self.BlueprintID].General.UpgradesTo then
				ChangeState(self, self.UpgradingState)
			end
		end
    end,

    OnStopBeingBuilt = function(self,builder,layer)

        UnitOnStopBeingBuilt(self,builder,layer)

        self:PlayActiveAnimation()
    end,

	-- this catches enhancements to structures
    OnCmdrUpgradeFinished = function(self)
    end,

    OnCmdrUpgradeStart = function(self)
    end,

	PlayActiveAnimation = function(self)
	end,


	-- LAUNCH SELF UPGRADES --
	-- syntax reference :  unit, faction, brain, masslowtrigger, energylowtrigger, masshightrigger, energyhightrigger, checkrate(seconds), initialdelay(seconds), bypassecon check

	-- the triggers control the parameters between which the self upgrade can take place
	LaunchUpgradeThread = function( finishedUnit, aiBrain )

        local FactionIndex          = aiBrain.FactionIndex
		local SelfUpgradeThread     = import('/lua/ai/aibehaviors.lua').SelfUpgradeThread
        local PlatoonCallForHelpAI  = import('/lua/platoon.lua').Platoon.PlatoonCallForHelpAI
        
        local checkrate, initialdelay

		--- factories --
		if EntityCategoryContains( FACTORIES, finishedUnit ) then

            checkrate = 16.5        
            initialdelay = 132

            -- after 30 minutes factories have NO upgrade delay period
            -- and will check for being able to upgrade at a faster rate
            if aiBrain.CycleTime > 1800 then

                checkrate = 13.5
                initialdelay = 1

            end

			if not finishedUnit.UpgradeThread then
                -- notice the additional parameter at the end, tells the threat to post a note, over the unit, each time the thread runs
				finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, 1.004, 1.005, 9999, 9999, checkrate, initialdelay, true, ScenarioInfo.DisplayFactoryBuilds )
			end
		end

		--- power generation --
		if EntityCategoryContains( ENERGYPRODUCTION, finishedUnit ) then

			if not finishedUnit.UpgradeThread then
            
                if EntityCategoryContains( categories.TECH2, finishedUnit ) then
                
                    checkrate = 15
                    initialdelay = 90

                    finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, 1.0032, 0.74, 9999, 1.8, checkrate, initialdelay, true, ScenarioInfo.StructureUpgradeDialog )
                    
                else
                
                    checkrate = 14
                    initialdelay = 100
                
                    finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, 0.85, 0.74, 9999, 1.8, checkrate, initialdelay, true, ScenarioInfo.StructureUpgradeDialog )
                
                end

			end
		end

		--- hydrocarbon --
		if EntityCategoryContains( categories.HYDROCARBON, finishedUnit ) then

			-- each hydro gets it's own platoon so we can enable PlatoonDistress calls for them
			local Mexplatoon = MakePlatoon( aiBrain, 'HYDROPlatoon'..tostring(finishedUnit.EntityID), 'none')

			Mexplatoon.BuilderName = 'HYDROPlatoon'..tostring(finishedUnit.EntityID)
			Mexplatoon.MovementLayer = 'Land'
            Mexplatoon.UsingTransport = true        -- never review this platoon during a merge

            AssignUnitsToPlatoon( aiBrain, Mexplatoon, {finishedUnit}, 'Support', 'none' )

            -- start a call for help thread triggered by at least 1.5 threat - was 3
			Mexplatoon:ForkThread( PlatoonCallForHelpAI, aiBrain, 1.5 )

			if not finishedUnit.UpgradeThread then
                
                checkrate = 16
                initialdelay = 110
  
				finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, 1.0045, 0.76, 9999, 1.8, checkrate, initialdelay, true, ScenarioInfo.StructureUpgradeDialog )

			end
		end

		--- mass extractors --
        if EntityCategoryContains( categories.MASSEXTRACTION, finishedUnit ) then

			-- each mex gets it's own platoon so we can enable PlatoonDistress calls for them
			local Mexplatoon = MakePlatoon( aiBrain, 'MEXPlatoon'..tostring(finishedUnit.EntityID), 'none')

			Mexplatoon.BuilderName = 'MEXPlatoon'..tostring(finishedUnit.EntityID)
			Mexplatoon.MovementLayer = 'Land'
            Mexplatoon.UsingTransport = true        -- never review this platoon during a merge

            AssignUnitsToPlatoon( aiBrain, Mexplatoon, {finishedUnit}, 'Support', 'none' )

			Mexplatoon:ForkThread( PlatoonCallForHelpAI, aiBrain, 1.5 )

			if not finishedUnit.UpgradeThread then
                
                checkrate = 13.5
                initialdelay = 70

				finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, .74, 1.0032, 1.8, 9999, checkrate, initialdelay, true, ScenarioInfo.StructureUpgradeDialog )

			end
        end

		--- mass fabricators --
        if EntityCategoryContains( categories.MASSFABRICATION, finishedUnit ) then

			-- each mex gets it's own platoon so we can enable PlatoonDistress calls for them
			local Mexplatoon = MakePlatoon( aiBrain, 'FABPlatoon'..tostring(finishedUnit.EntityID), 'none')

			Mexplatoon.BuilderName = 'FABPlatoon'..tostring(finishedUnit.EntityID)
			Mexplatoon.MovementLayer = 'Land'
            Mexplatoon.UsingTransport = true        -- never review this platoon during a merge

            AssignUnitsToPlatoon( aiBrain, Mexplatoon, {finishedUnit}, 'Support', 'none' )

			Mexplatoon:ForkThread( PlatoonCallForHelpAI, aiBrain, 5 )

			if not finishedUnit.UpgradeThread then

                checkrate = 16
                initialdelay = 85

				finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, .74, 1.002, 9999, 9999, checkrate, initialdelay, true, ScenarioInfo.StructureUpgradeDialog )

			end
        end

		--- shields --
        if EntityCategoryContains( categories.SHIELD, finishedUnit ) then

			if not finishedUnit.UpgradeThread then

                checkrate = 24
                initialdelay = 150

				finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, 1.008, 1.0115, 9999, 9999, checkrate, initialdelay, false, ScenarioInfo.StructureUpgradeDialog )

			end
        end

		--- radar and sonar --
        if EntityCategoryContains( INTEL, finishedUnit ) then

			if not finishedUnit.UpgradeThread then

                checkrate = 24
                initialdelay = 150

			    finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, 1.009, 1.02, 9999, 9999, checkrate, initialdelay, false, ScenarioInfo.StructureUpgradeDialog )

			end
        end

		-- pick up any structure that has an upgrade not covered by above
		if __blueprints[finishedUnit.BlueprintID].General.UpgradesTo != '' and not finishedUnit.UpgradeThread then

            checkrate = 36
            initialdelay = 300

			finishedUnit.UpgradeThread = finishedUnit:ForkThread( SelfUpgradeThread, FactionIndex, aiBrain, 1.012, 1.03, 9999, 9999, checkrate, initialdelay, false, ScenarioInfo.StructureUpgradeDialog )
		end

		-- add thread to the units trash
		if finishedUnit.UpgradeThread then

			TrashAdd( finishedUnit.Trash, finishedUnit.UpgradeThread )
		end

		if finishedUnit.EnhanceThread then

			TrashAdd( finishedUnit.Trash, finishedUnit.EnhanceThread)
		end

	end,

    StartBeingBuiltEffects = function(self, builder, layer)

		UnitStartBeingBuiltEffects(self, builder, layer)

		local bp = __blueprints[self.BlueprintID].General

		if bp.FactionName == 'UEF' then

			HideBone( self, 0, true)

			self.BeingBuiltShowBoneTriggered = false

			if bp.UpgradesFrom != builder.BlueprintID then
				self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag )
			end

		elseif bp.FactionName == 'Aeon' then

			if bp.UpgradesFrom != builder.BlueprintID then
				self:ForkThread( CreateAeonBuildBaseThread, builder, self.OnBeingBuiltEffectsBag )
			end

        elseif bp.FactionName == 'Seraphim' then

            if bp.UpgradesFrom != builder.BlueprintID then
                self:ForkThread( CreateSeraphimBuildBaseThread, builder, self.OnBeingBuiltEffectsBag )
            end
        end
    end,

    StopBeingBuiltEffects = function(self, builder, layer)

        local FactionName = __blueprints[self.BlueprintID].General.FactionName

        if FactionName == 'Aeon' then
            WaitTicks(18)

        elseif FactionName == 'UEF' and not self.BeingBuiltShowBoneTriggered then
            self:ShowBone(0, true)
            self:HideLandBones()

        end

        self.BeingBuiltShowBoneTriggered = nil        

		UnitStopBeingBuiltEffects(self, builder, layer)
    end,

    StartUpgradeEffects = function(self, unitBeingBuilt)
        HideBone( unitBeingBuilt, 0, true )
    end,

    StopUpgradeEffects = function(self, unitBeingBuilt)
        unitBeingBuilt:ShowBone(0, true)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)

		self:DestroyAdjacentEffects()
        
        self:DestroyTarmac()

        UnitOnKilled(self, instigator, type, overkillRatio)
    end,

    -- When we're adjacent, try all the possible bonuses.
    OnAdjacentTo = function(self, adjacentUnit, triggerUnit)

        local adjBuffs = __blueprints[self.BlueprintID].Adjacency

        if adjBuffs then

            if IsBeingBuilt(self) or IsBeingBuilt(adjacentUnit) then
                return
            end

            if ScenarioInfo.UnitDialog then
                LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." OnAdjacentTo "..repr(adjacentUnit.BlueprintID).." on tick "..GetGameTick())
            end

			for k,v in import('/lua/sim/adjacencybuffs.lua')[adjBuffs] do
				ApplyBuff(adjacentUnit, v, self)
			end

			self:RequestRefreshUI()
			adjacentUnit:RequestRefreshUI()
		else
            return
        end
    end,

    -- When we're not adjacent, try to remove all the possible bonuses.
    OnNotAdjacentTo = function(self, adjacentUnit)

        local adjBuffs = __blueprints[self.BlueprintID].Adjacency

        if adjBuffs and import('/lua/sim/adjacencybuffs.lua')[adjBuffs] then

            if ScenarioInfo.UnitDialog then
                LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." OnNotAdjacentTo "..repr(adjacentUnit.BlueprintID).." on tick "..GetGameTick())
            end

            for k,v in import('/lua/sim/adjacencybuffs.lua')[adjBuffs] do
			
                if HasBuff(adjacentUnit, v) then
                    RemoveBuff(adjacentUnit, v, false, self)
                end
				
            end

			self:DestroyAdjacentEffects(adjacentUnit)

			self:RequestRefreshUI()
			adjacentUnit:RequestRefreshUI()
		end
    end,

    CreateAdjacentEffect = function(adjacentUnit, self)

        if not self.AdjacencyBeamsBag then
		
            self.AdjacencyBeamsBag = {}
			
		else

			-- see if we already have an adjacency effect to this unit
			for k,v in self.AdjacencyBeamsBag do

				if v.Unit == adjacentUnit.EntityID then
					return
				end
                
			end
			
		end

		CreateAdjacencyBeams( self, adjacentUnit )

    end,

    DestroyAdjacentEffects = function(self, adjacentUnit)

        if self.AdjacencyBeamsBag then
        
            local UnitDialog = ScenarioInfo.UnitDialog
    
            if UnitDialog then
                LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." "..self.BlueprintID.." DestroyAdjacentEffects to "..repr(adjacentUnit.EntityID).." bag is "..repr(self.AdjacencyBeamsBag).." on tick "..GetGameTick())
            end

			for k, v in self.AdjacencyBeamsBag do

				local unit

                unit = adjacentUnit.EntityID
                
                if not adjacentUnit then
                    unit = v.Unit
                end    

				-- adjacency beams persist until either unit has been destroyed
				-- even if one of them is a production unit that might be turned off
				if unit == v.Unit then

                    if UnitDialog then
                        LOG("*AI DEBUG Destroy AdjacentEffects from "..self.EntityID.." to unit "..v.Unit )
                    end

					v.Trash:Destroy()

                    self.AdjacencyBeamsBag[k] = nil
                
                end

			end
		end
    end,

    OnTransportAttach = function(self, attachBone, unit)
		UnitOnTransportAttach(self, attachBone, unit)
    end,

    OnTransportDetach = function(self, attachBone, unit)
		UnitOnTransportDetach(self, attachBone, unit)
    end,
    
    OnUpgradeComplete = function( self )
    
        local aiBrain = GetAIBrain(self)
    
        if ScenarioInfo.StructureUpgradeDialog then    
            LOG("*AI DEBUG "..aiBrain.Nickname.." STRUCTUREUpgrade "..self.EntityID.." UpgradeComplete on game tick "..GetGameTick() )
		end
        
        if self.LaunchUpgradeThread then
            self:LaunchUpgradeThread( aiBrain )
        end
    end
  
}

local StructureUnitOnCreate             = StructureUnit.OnCreate
local StructureUnitOnKilled             = StructureUnit.OnKilled
local StructureUnitOnStopBeingBuilt     = StructureUnit.OnStopBeingBuilt
local StructureUnitOnStartBuild         = StructureUnit.OnStartBuild
local StructureUnitOnStopBuild          = StructureUnit.OnStopBuild
local StructureUnitOnTransportAttach    = StructureUnit.OnTransportAttach
local StructureUnitOnTransportDetach    = StructureUnit.OnTransportDetach

MobileUnit = Class(Unit) {

	OnPreCreate = function(self)

		UnitOnPreCreate(self)

		self.TransportClass = __blueprints[self.BlueprintID].Transport.TransportClass or false
	end,

    OnKilled = function(self, instigator, type, overkillRatio)

        local bp = __blueprints[self.BlueprintID].Defense
        
        if bp.AirThreatLevel > 0 or bp.SurfaceThreatLevel > 0 or bp.SubThreatLevel > 0 then

            local ArmyIndex = GetAIBrain(self).ArmyIndex
            local BRAINS = ArmyBrains
            local position = self:GetPosition()
        
            for k, brain in BRAINS do
            
                local function delaythreat( brain, position, threatamount, threattype)
                
                    local WaitTicks = coroutine.yield
                    local fastamount = threatamount * .02
                    local assign = moho.aibrain_methods.AssignThreatAtPosition
                
                    -- immediately reduce the IMAP threat of the unit but make sure this is fully decayed
                    -- by the time the natural decay begins
                    assign( brain, position, -threatamount, 0.05, threattype)

                    -- this is the delay built-in for anti-threat before decline begins
                    WaitTicks(291)

                    for i = 1, 50 do
                        -- and this is here to counter the negative threat that will get generated
                        assign( brain, position, fastamount, 1, threattype)
                        WaitTicks(31)
                    end
                end
                
                if IsEnemy( ArmyIndex, brain.ArmyIndex ) then
                
                    if bp.AirThreatLevel > 0 then
                        ForkTo ( delaythreat, brain, position, bp.AirThreatLevel, 'AntiAir' )
                    end
                    
                    if bp.SubThreatLevel > 0 then
                        ForkTo ( delaythreat, brain, position, bp.SubThreatLevel, 'AntiSub' )
                    end
                    
                    if bp.SurfactThreatLevel > 0 then
                        ForkTo ( delaythreat, brain, position, bp.SurfaceThreatLevel, 'AntiSurface' )
                    end

                end
                
            end
            
        end
        
        UnitOnKilled(self, instigator, type, overkillRatio)
    end,

	-- when you start capturing a unit
    OnStartCapture = function(self, target)
        self:DoUnitCallbacks( 'OnStartCapture', target )
        self:StartCaptureEffects(target)
        PlayUnitSound(self,'StartCapture')
        self:PlayUnitAmbientSound('CaptureLoop')
    end,

	-- when you capture a unit
    OnStopCapture = function(self, target)
        self:DoUnitCallbacks( 'OnStopCapture', target )
        self:StopCaptureEffects(target)
        PlayUnitSound(self,'StopCapture')
        self:StopUnitAmbientSound('CaptureLoop')
    end,

	-- when you fail to capture a unit
    OnFailedCapture = function(self, target)
        self:DoUnitCallbacks( 'OnFailedCapture', target )
        self:StopCaptureEffects(target)
        PlayUnitSound(self,'FailedCapture')
    end,

    StartCaptureEffects = function( self, target )
        if not self.CaptureEffectsBag then
            self.CaptureEffectsBag = TrashBag()
        end
		TrashAdd( self.CaptureEffectsBag, self:ForkThread( self.CreateCaptureEffects, target ) )
    end,

    CreateCaptureEffects = function( self, target )
        PlayCaptureEffects( self, target, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones or {0,}, self.CaptureEffectsBag )
    end,

    StopCaptureEffects = function( self, target )
		if self.CaptureEffectsBag then
			TrashDestroy(self.CaptureEffectsBag)
		end
    end,
	
    -- Return the total time in seconds, cost in energy, and cost in mass to capture the given target.
    GetCaptureCosts = function(self, target_entity)

        local target_bp = __blueprints[target_entity.BlueprintID].Economy

        local time = ( (target_bp.BuildTime or 10) / self:GetBuildRate() ) / 2
        local energy = target_bp.BuildCostEnergy or 100
        time = time * (self.CaptureTimeMultiplier or 1)

        return time, energy, 0
    end,
	
	-- when you start reclaiming
    OnStartReclaim = function(self, target)
        
        self:DoUnitCallbacks('OnStartReclaim', target)
		
        self:StartReclaimEffects(target)

        if not self.ReclaimEffectsBag then
            self.ReclaimEffectsBag = TrashBag()
        end

		TrashAdd( self.ReclaimEffectsBag, self:ForkThread( self.CreateReclaimEffects, target ) )

        PlayUnitSound(self,'StartReclaim')
		
		if IsUnit(target) and not target.BeingReclaimed then
		
			target.BeingReclaimed = true
			
			target:SetRegenRate(0)
		end

    end,

	-- when you stop reclaiming
    OnStopReclaim = function(self, target)

        self.Reclaiming = nil
        
        self:DoUnitCallbacks('OnStopReclaim', target)

		if self.ReclaimEffectsBag then
			TrashDestroy(self.ReclaimEffectsBag)
		end
        
		
		if target and not BeenDestroyed(target) and target.BeingReclaimed then
		
			target:RevertRegenRate()
			target.BeingReclaimed = false
			
		end

		--self:StopUnitAmbientSound('ReclaimLoop')
		--PlayUnitSound(self,'StopReclaim')
    end,
	
    CreateReclaimEffects = function( self, target )
        PlayReclaimEffects( self, target, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones or {0,}, self.ReclaimEffectsBag )
    end,

    CreateReclaimEndEffects = function( self, target )
        PlayReclaimEndEffects( self, target )
    end,

    StartReclaimEffects = function( self, target )

        if not self.ReclaimEffectsBag then
            self.ReclaimEffectsBag = TrashBag()
        end

		TrashAdd( self.ReclaimEffectsBag, self:ForkThread( self.CreateReclaimEffects, target ) )
    end,

    StopReclaimEffects = function( self, target )
		self.ReclaimEffectsBag:Destroy()
    end,

    SetReclaimTimeMultiplier = function(self, time_mult)
        self.ReclaimTimeMultiplier = time_mult
    end,
	
    OnStartSacrifice = function(self, target_unit)
		PlaySacrificingEffects(self,target_unit)
    end,

    OnStopSacrifice = function(self, target_unit)
		PlaySacrificeEffects(self,target_unit)
        
        self:SetDeathWeaponEnabled(false)
        self:Destroy()
    end,

    UpdateMovementEffectsOnMotionEventChange = function( self, new, old )
	
		if ( old == 'Stopped' or old == 'Stopping' or (old == 'TopSpeed' and self.TopSpeedEffectsBag) ) or ( (new == 'TopSpeed' and self.HasFuel)  or  new == 'Stopped' ) then

			local bpMTable = __blueprints[self.BlueprintID].Display.MovementEffects

			if (old == 'TopSpeed') and self.TopSpeedEffectsBag then
				self:DestroyTopSpeedEffects()
			end

			-- this should catch only air units
			if new == 'TopSpeed' and self.HasFuel then

				if bpMTable[self.CacheLayer].Contrails and self.ContrailEffects then
					self:CreateContrails( bpMTable[self.CacheLayer].Contrails )
				end

				if bpMTable[self.CacheLayer].TopSpeedFX then
					self:CreateMovementEffects( 'TopSpeedEffectsBag', 'TopSpeed' )
				end

			end

			if (old == 'Stopped' and new != 'Stopping') or (old == 'Stopping' and new != 'Stopped') then

				self:DestroyIdleEffects()
				self:DestroyMovementEffects()

				self:CreateMovementEffects( 'MovementEffectsBag', nil )

				if bpMTable.BeamExhaust then
					self:UpdateBeamExhaust( 'Cruise' )
				end

				if self.Detector then
					self.Detector:Enable()
				end

			end

			if new == 'Stopped' then

				self:DestroyMovementEffects()
				self:DestroyIdleEffects()
				self:CreateIdleEffects()

				if bpMTable.BeamExhaust then
					self:UpdateBeamExhaust( 'Idle' )
				end

				if self.Detector then
					self.Detector:Disable()
				end

			end
	
		
		end
		
    end,

    GetTTTreadType = function( self, pos )
        local TerrainType = GetTerrainType( pos.x,pos.z )
        return TerrainType.Treads or 'None'
    end,

    CreateTreads = function(self, treads)

        if treads.ScrollTreads then
            self:AddThreadScroller(1.0, treads.ScrollMultiplier or 0.2)
        end

        if treads.TreadMarks then

            local terraintype = self:GetTTTreadType(GetPosition(self))

            if terraintype != 'None' then
		
				self.TreadThreads = {}
		
				local counter = 0
			
                for k, v in treads.TreadMarks do
                
					counter = counter + 1                
                    self.TreadThreads[counter] = self:ForkThread(self.CreateTreadsThread, v, terraintype )

                end
				
            end
        end
    end,

    CreateTreadsThread = function(self, treads, terraintype )
	
        local sizeX = treads.TreadMarksSizeX
        local sizeZ = treads.TreadMarksSizeZ
		
        local interval      = treads.TreadMarksInterval * 10 + 1
		
        local treadOffset   = treads.TreadOffset
        local treadBone     = treads.BoneName or 0
        local treadTexture  = treads.TreadMarks
        local duration      = treads.TreadLifeTime or 10
		
        local army = self.Army

        local CSPLATON = CreateSplatOnBone
		local WaitTicks = coroutine.yield

        -- Syntatic reference
        -- CreateSplatOnBone(entity, offset, boneName, textureName, sizeX, sizeZ, lodParam, duration, army)
        while true do
            CSPLATON(self, treadOffset, treadBone, treadTexture, sizeX, sizeZ, 130, duration, army)
            WaitTicks(interval)
        end
    end,

    CreateFootFallManipulators = function( self, footfall )

        self.Detector = CreateCollisionDetector(self)
        
        TrashAdd( self.Trash, self.Detector )

        for k, v in footfall.Bones do
		
            self.Detector:WatchBone(v.FootBone)
			
            if v.FootBone and v.KneeBone and v.HipBone then
                CreateFootPlantController(self, v.FootBone, v.KneeBone, v.HipBone, v.StraightLegs or true, v.MaxFootFall or 0):SetPrecedence(10)
            end
			
        end
		
        return true
    end,

    CreateContrails = function(self, tableData )
	
		-- If SimSpeed drops too low -- curtail movement effects
		if Sync.SimData.SimSpeed < 0 then return end

        local army = self.Army
        local CreateTrail = CreateTrail
        local EffectBones = tableData.Bones
        local LOUDINSERT = LOUDINSERT

        local ZOffset = tableData.ZOffset or 0.0

        for _, ve in self.ContrailEffects do

            if not self.TopSpeedEffectsBag then
				self.TopSpeedEffectsBag = {}
			end
		
            for _, vb in EffectBones do
                LOUDINSERT( self.TopSpeedEffectsBag, CreateTrail( self, vb, army, ve ):SetEmitterParam( 'POSITION_Z', ZOffset ) )
            end
        end
		
    end,

    CreateMovementEffects = function( self, EffectsBag, TypeSuffix, TerrainType )
	
		-- If SimSpeed drops too low -- curtail movement effects
		if Sync.SimData.SimSpeed < 0 then return end

        local bpTable = __blueprints[self.BlueprintID].Display.MovementEffects
        local CacheLayer = self.CacheLayer

		if bpTable[CacheLayer] then

			bpTable = bpTable[CacheLayer]

			if bpTable.CameraShake then
				self.CamShakeT1 = self:ForkThread(self.MovementCameraShakeThread, bpTable.CameraShake )
			end

			if bpTable.Treads then
				self:CreateTreads( bpTable.Treads )
			else
				self:RemoveScroller()
			end

			if not bpTable.Effects[1] then
				return false
			end
            
            --LOG("*AI DEBUG Create Movement Effect for "..repr(CacheLayer))

			self:CreateTerrainTypeEffects( bpTable.Effects, 'FXMovement', CacheLayer, TypeSuffix, EffectsBag, TerrainType )

		end

    end,

    OnTerrainTypeChange = function(self, new, old)

        if self.MovementEffectsExist then

            self:DestroyMovementEffects()

            self:CreateMovementEffects( 'MovementEffectsBag', nil, new )
        end

    end,

	-- when a unit has an animation and the animation collides
	-- see if the unit has Footfall entries and process them for
	-- damage, shake, groundeffects, treads and audio cues
    OnAnimCollision = function(self, bone, x, y, z)

		-- if it even has Movement Effects -- many dont --
        if __blueprints[self.BlueprintID].Display.MovementEffects[self.CacheLayer] then
        
            local CacheLayer = self.CacheLayer
            local GetTerrainTypeEffects = self.GetTerrainTypeEffects

			-- then see if it has footfall entries for this layer
            local bpTable = __blueprints[self.BlueprintID].Display.MovementEffects[CacheLayer].Footfall

            if bpTable then

                if bpTable.Damage then
                    local bpDamage = bpTable.Damage
                    DamageArea(self, self:GetPosition(bone), bpDamage.Radius, bpDamage.Amount, bpDamage.Type, bpDamage.DamageFriendly )
                end

                if bpTable.CameraShake then
                    local shake = bpTable.CameraShake
                    self:ShakeCamera( shake.Radius, shake.MaxShakeEpicenter, shake.MinShakeAtRadius, shake.Interval )
                end

                if bpTable.Bones then

                    local army = self.Army

                    local effects = false

                    local scale = 1

                    local boneTable, offset

                    for k, v in bpTable.Bones do

                        if bone == v.FootBone then

                            boneTable = v
                            bone = v.FootBone
                            scale = boneTable.Scale or 1
                            offset = bone.Offset

                            if v.Type then
                                effects = GetTerrainTypeEffects( 'FXMovement', CacheLayer, self:GetPosition(v.FootBone), v.Type )
                            end

                            break
                        end
                    end
                    
                    local Tread = boneTable.Tread

                    if Tread and self:GetTTTreadType(self:GetPosition(bone)) != 'None' then
                    
                        local Tread = boneTable.Tread

                        CreateSplatOnBone(self, Tread.TreadOffset, 0, Tread.TreadMarks, Tread.TreadMarksSizeX, Tread.TreadMarksSizeZ, 100, Tread.TreadLifeTime or 8, army )

                        local treadOffsetX = Tread.TreadOffset[1]

                        if x and x > 0 then

                            if CacheLayer != 'Seabed' then
                                PlayUnitSound(self,'FootFallLeft')
                            else
                                PlayUnitSound(self,'FootFallLeftSeabed')
                            end

                        elseif x and x < 0 then

                            if CacheLayer != 'Seabed' then
                                PlayUnitSound(self,'FootFallRight')
                            else
                                PlayUnitSound(self,'FootFallRightSeabed')
                            end
                        end
                    end

                    if effects then
                        
                        for k, v in effects do
                            CreateEmitterAtBone(self, bone, army, v):ScaleEmitter(scale):OffsetEmitter(offset.x or 0,offset.y or 0,offset.z or 0)
                        end
                    end

                    if CacheLayer != 'Seabed' then
                        PlayUnitSound(self,'FootFallGeneric')
                    else
                        PlayUnitSound(self,'FootFallGenericSeabed')
                    end
                end
            end
        end
    end,

    CreateMotionChangeEffects = function( self, new, old )
	
		-- If SimSpeed drops too low -- curtail movement effects
		if Sync.SimData.SimSpeed < 0 then return end
        
        local MotionEffects = __blueprints[self.BlueprintID].Display.MotionChangeEffects or false

		if MotionEffects then

			local Effects = MotionEffects[self.CacheLayer..old..new] or false

			if bpTable then
				self:CreateTerrainTypeEffects( Effects, 'FXMotionChange', key, nil, 'IdleEffectsBag' )
			end
		end
    end,

    DestroyMovementEffects = function( self )

        local bpTable = __blueprints[self.BlueprintID].Display.MovementEffects
        
        --LOG("*AI DEBUG Destroy Movement Effects "..repr(self.MovementEffectsBag))

        CleanupEffectBag(self,'MovementEffectsBag')

        if self.CamShakeT1 then

            KillThread( self.CamShakeT1 )

            local shake = bpTable[self.CacheLayer].CameraShake

            if shake and shake.Radius and shake.MaxShakeEpicenter and shake.MinShakeAtRadius then
                self:ShakeCamera( shake.Radius, shake.MaxShakeEpicenter * 0.25, shake.MinShakeAtRadius * 0.25, 1 )
            end
        end

        if self.TreadThreads then
			
            for k, v in self.TreadThreads do
                KillThread(v)
            end
			
            self.TreadThreads = {}
        end

        if bpTable[self.CacheLayer].Treads.ScrollTreads then
			
            self:RemoveScroller()
        end
    end,

    DestroyTopSpeedEffects = function( self )
		CleanupEffectBag(self,'TopSpeedEffectsBag')
    end,

	-- issued by a unit as it gets attached to a transport
    OnStartTransportBeamUp = function(self, transport, bone)

        self:DestroyIdleEffects()
        self:DestroyMovementEffects()

		if not self.TransportBeamEffectsBag then
			self.TransportBeamEffectsBag = {}
		end
        
        local army = self.Army

        LOUDINSERT( self.TransportBeamEffectsBag, LOUDATTACHBEAMENTITY( self, -1, transport, bone, army, EffectTemplate.TTransportBeam01))
        LOUDINSERT( self.TransportBeamEffectsBag, LOUDATTACHBEAMENTITY( transport, bone, self, -1, army, EffectTemplate.TTransportBeam02))
        LOUDINSERT( self.TransportBeamEffectsBag, CreateEmitterAtBone( transport, bone, army, EffectTemplate.TTransportGlow01) )

        self:TransportAnimation()
    end,

	-- issued by the unit after being attached to transport stops
    OnStopTransportBeamUp = function(self)

        self:DestroyIdleEffects()
        self:DestroyMovementEffects()

        for _, v in self.TransportBeamEffectsBag do
            v:Destroy()
        end

		self.TransportBeamEffectsBag = nil
    end,

    TransportAnimation = function(self, rate)
        self:ForkThread( self.TransportAnimationThread, rate )
    end,

    TransportAnimationThread = function(self,rate)

        if __blueprints[self.BlueprintID].Display.TransportAnimation then

			WaitTicks(1)

            local animBlock = (self:ChooseAnimBlock( __blueprints[self.BlueprintID].Display.TransportAnimation )).Animation


            if animBlock then
			
                if not self.TransAnimation then
                
                    self.TransAnimation = CreateAnimator(self)
                    
                    TrashAdd( self.Trash, self.TransAnimation )
                end

                PlayAnim( self.TransAnimation, animBlock )
                
                rate = rate or 1
                self.TransAnimation:SetRate(rate)

                WaitFor(self.TransAnimation)
            end
        end
    end,

    -- removes engine forced attachment bones for transports
    RemoveTransportForcedAttachPoints = function(self)

        -- this cancels the weird attachment bone manipulations, so transported units attach to the correct positions
        -- (probably only useful for custom transport units only). By brute51, this is not a bug fix.
        local nBones = GetBoneCount(self) - 1

        for k = 1, nBones do
            if LOUDFIND(self:GetBoneName(k), 'Attachpoint_') then
                self:EnableManipulators(k, false)
            end
        end
    end,

	OnStopBeingBuilt = function(self, builder, layer)
		
		UnitOnStopBeingBuilt(self, builder, layer)
		
        if self.CacheLayer == 'Water' then

            --self:StartRocking()

            local surfaceAnim = __blueprints[self.BlueprintID].Display.AnimationSurface

            if not self.SurfaceAnimator and surfaceAnim then
                self.SurfaceAnimator = CreateAnimator(self)
            end
			
            if surfaceAnim and self.SurfaceAnimator then
                PlayAnim( self.SurfaceAnimator, surfaceAnim ):SetRate(1)
            end
        end

	end,

    OnLayerChange = function(self, new, old)

		UnitOnLayerChange( self, new, old) 

        for i = 1, GetWeaponCount(self) do
        
            local wep = GetWeapon(self,i)
            
            if wep.WeaponIsEnabled then
                wep:SetValidTargetsForCurrentLayer(new, wep.bp)
            end
        end

        if new == 'Land' then

			local vis = self:GetStat('VISION', 0).Value
			
			-- return vision radius to current value
			if old == 'Seabed' then
				self:SetIntelRadius('Vision', vis)
			end
			
			self:EnableIntel('Vision')
			self:DisableIntel('WaterVision')

			self:EnableUnitIntel('Radar')

			self:SetSpeedMult(1)

		-- all these inclusions are to cover Amphib units being dropped into, or constructed on the seabed
		-- or to cover Sonar carrying aircraft (ie. Torpedo Bombers)
        elseif (old == 'Land' or old == 'Air' or old == 'None') and new == 'Seabed' then
            
			local vis       = self:GetStat('VISION', 0).Value
            local watervis  = self:GetStat('WATERVISION', 0).Value
			
			self:SetIntelRadius('Vision', watervis)

			self:EnableIntel('WaterVision')
			self:DisableIntel('Vision')

			self:DisableUnitIntel('Radar')

			local WaterSpeedMultiplier = __blueprints[self.BlueprintID].Physics.WaterSpeedMultiplier or false

			if WaterSpeedMultiplier then
				self:SetSpeedMult(WaterSpeedMultiplier)
			end

        end

		local bp = __blueprints[self.BlueprintID].Display

		-- if unit has footfalls and they are described for new layer then use them
        if self.Footfalls and bp.MovementEffects[new].Footfall then
            self.Footfalls = self:CreateFootFallManipulators( bp.MovementEffects[new].Footfall )
        end

        if self.MovementEffectsExist then
            self:DestroyMovementEffects()

            self:UpdateMovementEffectsOnMotionEventChange( new, old )
        end

		if bp.LayerChangeEffects then
			self:CreateLayerChangeEffects( new, old, bp.LayerChangeEffects )
		end
    end,

    CreateLayerChangeEffects = function( self, new, old, bp )

        local key = old..new

        if bp[key].Effects then
            self:CreateTerrainTypeEffects( bp[key].Effects, 'FXLayerChange', key )
        end

    end,

    OnMotionHorzEventChange = function( self, new, old )

        if self.Dead then
            return
        end

        if ( old == 'Stopped' or (old == 'Stopping' and (new == 'Cruise' or new == 'TopSpeed'))) then

            PlayUnitSound( self,'StartMove')

            self:PlayUnitAmbientSound('AmbientMove')

            self:StopRocking()

			if old == 'Stopped' and self.EventCallbacks.OnHorizontalStartMove then
				self:DoOnHorizontalStartMoveCallbacks()
			end
        end

        if (new == 'Stopped' or new == 'Stopping') then

			if (old == 'Cruise' or old == 'TopSpeed') then

				PlayUnitSound( self, 'StopMove')

				if self.CacheLayer == 'Water' then
					self:StartRocking()
				end
			end
            
			if new == 'Stopped' and self.EventCallbacks.OnHorizontalStopMove then
				self:DoOnHorizontalStopMoveCallbacks()
			end

            self:StopUnitAmbientSound( 'AmbientMove' )
            self:StopUnitAmbientSound( 'AmbientMoveWater' )
            self:StopUnitAmbientSound( 'AmbientMoveSub' )
            self:StopUnitAmbientSound( 'AmbientMoveLand' )
        end

        if self.MovementEffectsExist then
            self:UpdateMovementEffectsOnMotionEventChange( new, old )
        end

    end,

    AddOnHorizontalStartMoveCallback = function(self, fn)

		if not self.EventCallbacks.OnHorizontalStartMove then
			self.EventCallbacks.OnHorizontalStartMove = {}
		end

        LOUDINSERT(self.EventCallbacks.OnHorizontalStartMove, fn)
    end,

    DoOnHorizontalStartMoveCallbacks = function(self)

		if self.EventCallbacks.OnHorizontalStartMove then

			for k, cb in self.EventCallbacks.OnHorizontalStartMove do

				if cb then

					cb(self)
				end
			end
		end
    end,

    AddOnHorizontalStopMoveCallback = function(self, fn)

		if not self.EventCallbacks.OnHorizontalStopMove then
			self.EventCallbacks.OnHorizontalStopMove = {}
		end

        LOUDINSERT(self.EventCallbacks.OnHorizontalStopMove, fn)
    end,

    DoOnHorizontalStopMoveCallbacks = function(self)

		if self.EventCallbacks.OnHorizontalStopMove then

			for k, cb in self.EventCallbacks.OnHorizontalStopMove do

				if cb then

					cb(self)
				end
			end
		end
    end,

    OnMotionVertEventChange = function( self, new, old )

        if new == 'Bottom' then
            self:UpdateBeamExhaust('Landed')
        elseif old == 'Bottom' then
            self:UpdateBeamExhaust('Cruise')
        end

        -- Surfacing and sinking, landing and take off idle effects
        if (new == 'Up' and old == 'Bottom') or (new == 'Down' and old == 'Top') then
		
            self:DestroyIdleEffects()

			local layer = self.CacheLayer

            if new == 'Up' and layer == 'Sub' then
                PlayUnitSound(self,'SurfaceStart')
            end

            if new == 'Down' and layer == 'Water' then
                PlayUnitSound(self,'SubmergeStart')
                if self.SurfaceAnimator then
                    self.SurfaceAnimator:SetRate(-1)
                end
            end

        end

        if (new == 'Top' and old == 'Up') or (new == 'Bottom' and old == 'Down') then

			local layer = self.CacheLayer

            if new == 'Bottom' and layer == 'Sub' then
                PlayUnitSound(self,'SubmergeEnd')
            end

            if new == 'Top' and layer == 'Water' then
                PlayUnitSound(self,'SurfaceEnd')
                local surfaceAnim = __blueprints[self.BlueprintID].Display.AnimationSurface

                if not self.SurfaceAnimator and surfaceAnim then
                    self.SurfaceAnimator = CreateAnimator(self)
                end

                if surfaceAnim and self.SurfaceAnimator then
                    self.SurfaceAnimator:PlayAnim(surfaceAnim):SetRate(1)
                end
            end
        end

    end,

    StartBeingBuiltEffects = function(self, builder, layer)

        Unit.StartBeingBuiltEffects(self, builder, layer)

        if __blueprints[self.BlueprintID].General.FactionName == 'UEF' then
            CreateUEFUnitBeingBuiltEffects( self, builder, self.OnBeingBuiltEffectsBag )
        end
		
    end,

    StartRocking = function(self)
        --KillThread(self.StopRockThread)
        --self.StartRockThread = self:ForkThread( self.RockingThread )
    end,

    StopRocking = function(self)
        --KillThread(self.StartRockThread)
        --self.StopRockThread = self:ForkThread( self.EndRockingThread )
    end,
}

local MobileUnitOnKilled                = MobileUnit.OnKilled
local MobileUnitOnLayerChange           = MobileUnit.OnLayerChange
local MobileUnitOnPreCreate             = MobileUnit.OnPreCreate
local MobileUnitOnMotionHorzEventChange = MobileUnit.OnMotionHorzEventChange
local MobileUnitOnMotionVertEventChange = MobileUnit.OnMotionVertEventChange

FactoryUnit = Class(StructureUnit) {

    OnCreate = function(self)

        StructureUnitOnCreate(self)
        self.BuildingUnit = false

    end,

	OnStopBeingBuilt = function(self, builder,layer)

		self:SetMaintenanceConsumptionActive()

	end,

    OnPaused = function(self)

        self:StopUnitAmbientSound( 'ConstructLoop' )

		Unit.OnProductionPaused(self)

        StructureUnit.OnPaused(self)

    end,

    OnUnpaused = function(self)

        if self.BuildingUnit then
            self:PlayUnitAmbientSound( 'ConstructLoop' )
        end

		Unit.OnProductionUnpaused(self)

        StructureUnit.OnUnpaused(self)

    end,

    OnStartBuild = function(self, unitBeingBuilt, order )

        StructureUnitOnStartBuild(self, unitBeingBuilt, order )
        
        self.BuildingUnit = true

        if order != 'Upgrade' then
            ChangeState(self, self.BuildingState)
            self.BuildingUnit = false
        end

        self.FactoryBuildFailed = false

    end,

    OnStopBuild = function(self, unitBeingBuilt, order )

        StructureUnitOnStopBuild(self, unitBeingBuilt, order )

        if not self.FactoryBuildFailed then

            if not EntityCategoryContains(categories.AIR, unitBeingBuilt) then

                self:RollOffUnit()

            end

            self:StopBuildFx()

            self:ForkThread(self.FinishBuildThread, unitBeingBuilt, order )
		end            

        self.BuildingUnit = false
    end,

    FinishBuildThread = function(self, unitBeingBuilt, order )

        self:SetBusy(true)
        self:SetBlockCommandQueue(true)

        local bp = __blueprints[self.BlueprintID]
        local bpAnim = bp.Display.AnimationFinishBuildLand

        if bpAnim and EntityCategoryContains(categories.LAND, unitBeingBuilt) then

            self.RollOffAnim = CreateAnimator(self)
            
            PlayAnim( self.RollOffAnim, bpAnim )
            
            TrashAdd( self.Trash, self.RollOffAnim )
            
            WaitTicks(1)

            WaitFor(self.RollOffAnim)

        end

        if unitBeingBuilt and not unitBeingBuilt.Dead then

            unitBeingBuilt:DetachFrom(true)
        
            if EntityCategoryContains( SERAPHIMAIR, unitBeingBuilt) then
            
                self:DetachAll(bp.Display.BuildAttachBone or 0)
            
            end

        end

        self:DetachAll(bp.Display.BuildAttachBone or 0)
        self:DestroyBuildRotator()

        if order != 'Upgrade' then

            ChangeState(self, self.RollingOffState)

        else

            self:SetBlockCommandQueue(false)
            self:SetBusy(false)

        end

    end,

    OnFailedToBuild = function(self)

        self.FactoryBuildFailed = true

        StructureUnit.OnFailedToBuild(self)

        self:DestroyBuildRotator()
        self:StopBuildFx()

        ChangeState(self, self.IdleState)

    end,

    RollOffUnit = function(self)
        
        local vec = VectorCached
        local spin
        
        spin, vec[1], vec[2], vec[3] = self:CalculateRollOffPoint()

        self.MoveCommand = IssueMove( { self.UnitBeingBuilt }, vec )

    end,

	-- Just looking at how this works and realizing what the intent is
	-- Apparently the purpose is to have factories with multiple roll-off points
	-- and then this code would return the spin required to face a unit at the closest
	-- roll-off point which is nearest to the rally point of the factory - neat - but very few factories have the roll-off point specified
    CalculateRollOffPoint = function(self)

        local bp = __blueprints[self.BlueprintID].Physics.RollOffPoints

		local pos = LOUDCOPY(self.CachePosition)

		local px = pos[1]
		local py = pos[2]
		local pz = pos[3]

        if not bp then return 0, px, py, pz end

        local vectorObj = self:GetRallyPoint()
        local bpKey = 1
        local distance, lowest = nil

        for k, v in bp do

            distance = VDist2(vectorObj[1], vectorObj[3], v.X + px, v.Z + pz)

            if not lowest or distance < lowest then

                bpKey = k
                lowest = distance

            end

        end

        local fx, fy, fz, spin
        local bpP = bp[bpKey]
		
        local unitBP = __blueprints[self.UnitBeingBuilt.BlueprintID].Display.ForcedBuildSpin

        if unitBP then

            spin = unitBP

        else

            spin = bpP.UnitSpin

        end

        fx = bpP.X + px
        fy = bpP.Y + py
        fz = bpP.Z + pz

        return spin, fx, fy, fz

    end,

    StartBuildFx = function(self, unitBeingBuilt)
    end,

    StopBuildFx = function(self)

        if self.BuildAnimManip then
            self.BuildAnimManip:SetRate(0)
        end

    end,

    PlayFxRollOff = function(self)
    end,

    PlayFxRollOffEnd = function(self)

        if self.RollOffAnim then

            self.RollOffAnim:SetRate(-1)

			self.Trash:Add(self.RollOffAnim)

            WaitFor(self.RollOffAnim)

            self.RollOffAnim:Destroy()
            self.RollOffAnim = nil

        end

    end,

	CreateBlinkingLights = function(self,item)
	end,

	DestroyBlinkingLights = function(self,item)
	end,

    CreateBuildRotator = function(self, bone)

        if not self.BuildBoneRotator then
		
            local spin = self:CalculateRollOffPoint()

            self.BuildBoneRotator = CreateRotator(self, bone, 'y', spin, 10000)
			
            TrashAdd( self.Trash, self.BuildBoneRotator )
        end
    end,

    DestroyBuildRotator = function(self)

        if self.BuildBoneRotator then

            self.BuildBoneRotator:Destroy()
            self.BuildBoneRotator = nil

        end

    end,

	-- this function used to have a variable delay based upon
	-- waiting for the finished unit to complete it's movement order
	-- this was wasteful indeed - after some study -- I concluded that
	-- all units have cleared the gantry in a second and the factory
	-- should be ready to recieve new orders -- there was also some
	-- duplication of commands since the function calls to self.IdleState
	-- which already restores the Busy and CommandQueue conditions
    RolloffBody = function(self)

        self:SetBusy(true)
        self:SetBlockCommandQueue(true)

        self:PlayFxRollOff()

        if self.MoveCommand then
            WaitTicks(10)
	        self.MoveCommand = false
        end

		self:PlayFxRollOffEnd()

        ChangeState(self, self.IdleState)

    end,

    IdleState = State {

        Main = function(self)

            --self:ChangeBlinkingLights('Green')
            self:SetBusy(false)
            self:SetBlockCommandQueue(false)
            self:DestroyBuildRotator()

        end,
    },

    BuildingState = State {

        Main = function(self)

            local unitBuilding = self.UnitBeingBuilt

            local bone = __blueprints[self.BlueprintID].Display.BuildAttachBone or 0

            self:DetachAll(bone)

            unitBuilding:AttachBoneTo(-2, self, bone)

            self:CreateBuildRotator(bone)
			
            self:StartBuildFx(unitBuilding)

        end,
    },

    RollingOffState = State {

        Main = function(self)

            self:RolloffBody()

        end,
    },

    OnKilled = function(self, instigator, type, overkillRatio)

        StructureUnitOnKilled(self, instigator, type, overkillRatio)

        if self.UnitBeingBuilt and not BeenDestroyed(self.UnitBeingBuilt) and GetFractionComplete(self.UnitBeingBuilt) < 1 then

            self.UnitBeingBuilt:Destroy()

        end

    end,

	OnStopBeingBuilt = function(self,builder,layer)

       StructureUnitOnStopBeingBuilt(self,builder,layer)

	end,
}

function FactoryFixes( FactoryClass )

	-- This code is from CBFP4.0 -- Do not use for mobile factories!
    return Class(FactoryClass) {

        -- rolloff delay. See miscellaneous.txt file for more info
		-- by putting the RolloffDelay field into the factory blueprint you can
		-- have a definable wait period between factory builds

        OnStopBuild = function(self, unitBeingBuilt, order )

            local bp = __blueprints[self.BlueprintID].General

            if bp.RolloffDelay and bp.RolloffDelay > 0 and not self.FactoryBuildFailed then

                self:ForkThread( self.PauseThread, unitBeingBuilt, order, bp.RolloffDelay )

            else

                FactoryClass.OnStopBuild(self, unitBeingBuilt, order)

            end

        end,

        PauseThread = function( self, unitBeingBuilt, order, productionpause )

            self:StopBuildFx()

            if productionpause and productionpause > 0 then

                self:SetBusy(true)
                self:SetBlockCommandQueue(true)

                WaitSeconds(productionpause)

                self:SetBlockCommandQueue(false)
				self:SetBusy(false)
            end

            FactoryClass.OnStopBuild(self, unitBeingBuilt, order)

        end,
	}
end

FactoryUnit = FactoryFixes(FactoryUnit)

TeleportUnit = Class(StructureUnit) {

	-- Base economic costs for starting a teleport
	BaseChargeTime = 30,
	BaseEnergyCost = 5000,

	-- Resource costs for various unit tiers
	ResourceCosts = { Energy = { T1 = 25, T2 = 100,	T3 = 400, T4 = 3200, COMMAND = 1600	} },

	-- Sound that plays when a teleport happens
	TeleportSound = Sound { Bank = 'UAL', Cue = 'UAL0001_Gate_In', LodCutoff = 'UnitMove_LodCutoff'	},

	-- Set of effects that are played when a gate involved with an in-progress teleport is destroyed
	GateExplodeEffect = {
		{ Scale = 0.6, Offset = { x = 0, y = 0, z = 0 },
			Emitters = {
				'/effects/emitters/seraphim_inaino_hit_03_emit.bp',
				'/effects/emitters/seraphim_inaino_hit_08_emit.bp',
				'/effects/emitters/seraphim_inaino_hit_07_emit.bp',
				'/effects/emitters/seraphim_inaino_explode_07_emit.bp',
			},
		},
		{ Scale = 2.5, Offset = { x = 0, y = 0, z = 0 }, Emitters = {'/effects/emitters/aeon_sacrifice_01_emit.bp'}	},
		{ Scale = 4.0, Offset = { x = 0, y = 0, z = 0 }, Emitters = {'/effects/emitters/aeon_sacrifice_02_emit.bp'} },
	},

	-- Set of effects used when a teleport happens
	TeleportChargeEffect = {
		{ Scale = 0.48, Offset = { x = 0, y = 1.0, z = -2.50 }, Emitters = EffectTemplate.CSoothSayerAmbient },
		{ Scale = 1.75, Offset = { x = 0, y = 1.5, z = -0.00 }, Emitters = EffectTemplate.GenericTeleportCharge01 },
		{ Scale = 2.25, Offset = { x = 0, y = 2.4, z = -2.50 }, Emitters = EffectTemplate.SeraphimSubCommanderGateway02 },
	},

	-- Fires when the gateway finishes building. Used to set flags and prepare the gate
	-- for teleport stuff
	OnStopBeingBuilt = function(self, builder, layer)

		self.TeleportReady      = true			-- check if the gateway is ready to participate in teleporting
		self.TeleportingUnits   = nil			-- table holds the units currently being teleported
		self.DestinationGateway = nil		-- when this gate is sending, the gate we are sending to
		self.TeleportInProgress = false		-- true when a teleport is currently underway
        
        self.TeleportRadius = __blueprints[self.BlueprintID].Economy.MaxBuildDistance or 12

		self.TeleportChargeBag = {}

		self:SetMaintenanceConsumptionActive()
        
        self.WatchPower = self:ForkThread(self.WatchPowerThread, self)

		UnitOnStopBeingBuilt(self, builder, layer)
	end,

    -- this thread watches the E condition, and removes the toggle, and cancels any pending teleports
    WatchPowerThread = function( self )
	
        local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local aiBrain = self:GetAIBrain()
        local MaintenanceConsumption = __blueprints[self.BlueprintID].Economy.MaintenanceConsumptionPerSecondEnergy
        local on = true
        local stored

        while not self.Dead do
            
            stored = GetEconomyStored(aiBrain,'ENERGY')

            if on and stored < MaintenanceConsumption then
			
				self:RemoveToggleCap('RULEUTC_WeaponToggle')
                
                self:SetMaintenanceConsumptionInactive()

				on = false
                
                self:EndGateChargeEffect()
                
                -- if a teleport is underway --                
                if self.TeleportThread then
            
                    LOG("*AI DEBUG Teleport Event Aborted")
	
                    KillThread( self.TeleportThread)
                    self.TeleportThread = nil
                    
                    local warpUnits = import('/lua/CommonTools.lua').GetAlliedMobileUnitsInRadius(self, self:GetPosition(), self.TeleportRadius)
                    
                    for k,v in warpUnits do

                        if v.Dead then continue end

                        v:CleanupTeleportChargeEffects()
            
                        v:SetImmobile(false)
                    end
                    
                    RemoveEconomyEvent(self, self.TeleportDrain)
                    self.TeleportDrain = nil
                    
                    self:UpdateTeleportProgress(0.0)

                    self.TeleportingUnits = nil

                    self.TeleportInProgress = false

                    self:RemoveTeleportLink()

                end
			end
			
            -- don't come back on until we have 5 seconds of consumption stored
			if not on and stored > (MaintenanceConsumption * 5) then
            
                self:SetMaintenanceConsumptionActive()
				
				self:AddToggleCap('RULEUTC_WeaponToggle')
				on = true
			end
			
            WaitTicks(21)

        end	

	end,
	
	OnKilled = function(self, instigator, type, overkillRatio)

		if self.TeleportThread then
			KillThread(self.TeleportThread)
			self.TeleportThread	= nil
		end

		if self.TeleportInProgress then

			self:EndGateChargeEffect()

            -- fork a thread because of the effects used we need to sleep a few seconds for timing
            ForkThread(self.GateDeathEffectThread, self)

			-- if the gate destroyed is linked to a remote (receiving) gateway then kill it
			if self.DestinationGateway and not self.DestinationGateway:IsDead() then
				self.DestinationGateway:Kill(self, type, 1.0)
			end

			-- if the gate destroyed is linked to a remote (sending) gateway then kill it
			if self.SourceGateway and not self.SourceGateway:IsDead() then
				self.SourceGateway:Kill(self, type, 1.0)
			end

			-- it is the job of the sending gateway to kill any units being teleported
			if self.TeleportingUnits then
				for k, v in self.TeleportingUnits do
					v:CleanupTeleportChargeEffects()
					v:SetImmobile(false)
					v:Kill(self, type, 1.0)
				end
			end

			-- cleanup
			self.DestinationGateway = nil
			self.SourceGateway = nil
			self.TeleportInProgress = false

		end

		StructureUnitOnKilled(self, instigator, type, overkillRatio)
	end,

	-- This is the "main" function called when the teleport button is clicked
	WarpNearbyUnits	= function(self, radius)
    
        self:SetMaintenanceConsumptionInactive()

		if not self.TeleportReady then
			import('/lua/CommonTools.lua').PrintError("Teleport node not ready!", self.Army)
			return
		end

		if self.TeleportInProgress then
			import('/lua/CommonTools.lua').PrintError("Teleport already in progress!", self.Army)
			return
		end

		local warpLocation = self:GetRallyPoint()

		local possibleGates = self:GetAlliedTeleportersInRadius( warpLocation, radius)

		if not possibleGates[1] then
			import('/lua/CommonTools.lua').PrintError("No teleport node found at rally point", self.Army)
			return
		end

		-- just pick the first gate in the list, more than one gate within the teleport radius == WTF
		local destinationGate = possibleGates[1]

		if destinationGate == self then
			import('/lua/CommonTools.lua').PrintError("Must target a remote teleport node", self.Army)
			return
		end

		if destinationGate.TeleportInProgress then
			import('/lua/CommonTools.lua').PrintError("Target teleport node already busy!", self.Army)
			return
		end

		local warpUnits = import('/lua/CommonTools.lua').GetAlliedMobileUnitsInRadius(self, self:GetPosition(), radius)
        
        if not warpUnits[1] then
			import('/lua/CommonTools.lua').PrintError("No units in the teleport node area", self.Army)        
            return
        end

		if self.TeleportThread then
			RemoveEconomyEvent(self, self.TeleportDrain)
			self.TeleportDrain = nil
		end

		-- fire off a new thread to handle the teleport
		self.TeleportThread	= self:ForkThread(self.TeleportUnits, warpUnits, destinationGate)
	end,

	-- Handler for the economy event that will update the teleporter's progress
	UpdateTeleportProgress = function(self,	progress)
	
		self:SetWorkProgress(progress)

		if self.DestinationGateway then
			self.DestinationGateway:SetWorkProgress(progress)
		end
	end,

	-- Main thread function for playing gate death effects
	GateDeathEffectThread = function(self)

		local fx = nil
		local fxBag = { }
        local count = 0

		for k, v in self.GateExplodeEffect do
        
			for k, e in v.Emitters do
            
				fx = CreateEmitterAtEntity(self, self.Army, e):OffsetEmitter(v.Offset.x, v.Offset.y, v.Offset.z):ScaleEmitter(v.Scale)
                
                count = count + 1
				fxBag[count] = fx
			end
		end

		WaitSeconds(3)

		for k, v in fxBag do
			v:Destroy()
		end
	end,

	-- Plays the teleportation effect
	PlayGateTeleportEffect = function(self)

		-- upwards funnel
		for k, v in EffectTemplate.SIFInainoHit02 do
			CreateEmitterAtEntity(self, self.Army, v):ScaleEmitter(0.4)
			CreateEmitterAtEntity(self.DestinationGateway, self.DestinationGateway:GetArmy(), v):ScaleEmitter(0.28)
		end

        -- these created an undesirable splat crater that I didn't like very much
		--self:CreateProjectile('/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.1, 0, nil, nil, nil):SetCollision(false)
		--self.DestinationGateway:CreateProjectile('/effects/entities/UnitTeleport01/UnitTeleport01_proj.bp', 0, 1.1, 0, nil, nil, nil):SetCollision(false)

		WaitSeconds(2.15)

		-- flash!
		for k, v in EffectTemplate.SIFInainoHit01 do
			CreateEmitterAtEntity(self, self.Army, v):ScaleEmitter(0.48)
			CreateEmitterAtEntity(self.DestinationGateway, self.DestinationGateway:GetArmy(), v):ScaleEmitter(0.36)
		end

	end,

	-- Initiates the "teleport charging" effect on gateways involved
	StartGateChargeEffect = function(self)
	
		local army = self.Army
        local count = 0

		for k, v in self.TeleportChargeEffect do
        
			for k, e in v.Emitters do
                count = count + 1
				self.TeleportChargeBag[count] = CreateEmitterAtEntity(self, army, e):OffsetEmitter(v.Offset.x, v.Offset.y, v.Offset.z):ScaleEmitter(v.Scale)
			end
		end

		-- sending gateway tells remote gateway to charge up
		if self.DestinationGateway then
			self.DestinationGateway:StartGateChargeEffect()
		end
	end,

	-- Terminates the teleport charging effects
	EndGateChargeEffect = function(self)

		if self.TeleportChargeBag then

			for k, v in self.TeleportChargeBag do
				v:Destroy()
                self.TeleportChargeBag[k] = nil
			end
		end


		-- sending gateway tells remote gateway to stop charging
		if self.DestinationGateway then
			self.DestinationGateway:EndGateChargeEffect()
		end
	end,

	-- Plays the teleport sound at both gateways
	PlayTeleportSound = function(self)

		self:PlaySound(self.TeleportSound)

		if self.DestinationGateway then
			-- NOTE: this doesn't work. Only the sending gateway plays a sound
			-- No idea why...
			self.DestinationGateway:PlaySound(self.TeleportSound)
		end

	end,

	-- Main teleportation function thread
	TeleportUnits = function(self, warpUnits, destinationGate)

		self.TeleportInProgress = true
		destinationGate.TeleportInProgress = true

		self:RemoveToggleCap('RULEUTC_WeaponToggle')
 
		self.TeleportingUnits = warpUnits
		self:CreateTeleportLink(destinationGate)
		self:StartGateChargeEffect()

		local massCost = 0
		local energyCost = self.BaseEnergyCost
		local timeCost = self.BaseChargeTime

		-- calculate economic costs for teleport
		for k, v in warpUnits do

			if v.GetPosition then

				IssueStop( { v } )
				IssueClearCommands( { v } )
				v:SetImmobile(true)

				v:PlayScaledTeleportChargeEffects()

				local cats = __blueprints[v.BlueprintID].Categories

				-- COMMAND is first because SCUs have both a COMMAND and a TECH3 category
				if table.find(cats, 'COMMAND') or table.find(cats, 'SUBCOMMANDER') then
					energyCost = energyCost + self.ResourceCosts.Energy.COMMAND

                    timeCost = math.max( timeCost, self.BaseChargeTime + 4 )

				elseif table.find(cats, 'TECH1') then
					energyCost = energyCost + self.ResourceCosts.Energy.T1

				elseif table.find(cats, 'TECH2') then
					energyCost = energyCost + self.ResourceCosts.Energy.T2
                    
                    timeCost = math.max( timeCost, self.BaseChargeTime + 2 )

				elseif table.find(cats, 'TECH3') then
					energyCost = energyCost + self.ResourceCosts.Energy.T3
                    
                    timeCost = math.max( timeCost, self.BaseChargeTime + 4 )

				elseif table.find(cats, 'EXPERIMENTAL') then
					energyCost = energyCost + self.ResourceCosts.Energy.T4
                    
                    timeCost = math.max( timeCost, self.BaseChargeTime + 10 )
                  
				else
					LOG("~Found UNKNOWN unit!")
				end
			end
		end

		-- we want cost PER SECOND, so multiply by time
		energyCost = energyCost * timeCost

		LOG("*AI DEBUG Teleport Econ Event Time "..timeCost.." Energy per second "..math.floor(energyCost/timeCost).." begins on Tick "..GetGameTick() )

		self.TeleportDrain = CreateEconomyEvent(self, energyCost, massCost, timeCost, self.UpdateTeleportProgress)

		WaitFor(self.TeleportDrain)

		LOG("*AI DEBUG Teleport Econ Event complete at tick "..GetGameTick() )

		if self.TeleportDrain then
			RemoveEconomyEvent(self, self.TeleportDrain)
			self.TeleportDrain = nil
		end

		self:UpdateTeleportProgress(0.0)

		local srcGatePos = table.copy(self:GetPosition())
		local dstGatePos = table.copy(self.DestinationGateway:GetPosition())
        
		--LOG("*AI DEBUG Teleport Source "..string.format("~gateway position: [%f, %f, %f]", srcGatePos[1], srcGatePos[2], srcGatePos[3]))
		--LOG("*AI DEBUG Teleport Destination "..string.format("~gateway position: [%f, %f, %f]", dstGatePos[1], dstGatePos[2], dstGatePos[3]))

		self:PlayTeleportSound()

		self:EndGateChargeEffect()
		self:PlayGateTeleportEffect()

		self:PlayScaledTeleportInEffects(0.60)
		self.DestinationGateway:PlayScaledTeleportInEffects(0.60)

		-- the main teleport loop. Moves all units to the destination gate
		for	k, v in	warpUnits do

			-- no rides for units killed during charge-up
			if v.Dead then continue end

			-- figure out the position of the unit relative to the sending gate, and use that relative position
			-- offset by the receiving gate's position to determine the final location to teleport a unit
			local curPos = table.copy(v:GetPosition())

			local xOffset = curPos[1] - srcGatePos[1]
			local yOffset = curPos[2] - srcGatePos[2]
			local zOffset = curPos[3] - srcGatePos[3]

			local newPos = { dstGatePos[1] + xOffset, dstGatePos[2] + yOffset, dstGatePos[3] + zOffset }

			v:CleanupTeleportChargeEffects()
			v:PlayScaledTeleportOutEffects()

			Warp( v, newPos )

			v:PlayScaledTeleportInEffects()
			v:CleanupTeleportChargeEffects()
            
			v:SetImmobile(false)
		end
        
        self:SetMaintenanceConsumptionActive()

		self:AddToggleCap('RULEUTC_WeaponToggle')

		self:RemoveTeleportLink()

		-- cleanup
		self.TeleportingUnits = nil
		self.TeleportThread = nil
		self.TeleportDrain = nil

		self.TeleportInProgress = false
	end,

	-- Creates a link between this gateway and a destination gateway
	CreateTeleportLink = function(self, dstGate)

		self.DestinationGateway = dstGate
		dstGate.SourceGateway = self
	end,

	-- Removes a link between gateways
	RemoveTeleportLink = function(self)

		local otherGate = self.DestinationGateway

		self.DestinationGateway = nil
		self.SourceGateway = nil

		if otherGate then
			otherGate.DestinationGateway = nil
			otherGate.SourceGateway = nil
            otherGate.TeleportInProgress = false
		end
	end,

	-- Teleport GUI button
	OnScriptBitSet = function(self,	bit)

		UnitOnScriptBitSet(self, bit)

		if bit == 1 then
			ForkThread(self.WarpNearbyUnits, self, self.TeleportRadius)
		end

		self:SetScriptBit('RULEUTC_WeaponToggle', false)
	end,

    GetAlliedTeleportersInRadius = function(unit, position, radius)

        local x1 = position[1] - radius
        local z1 = position[3] - radius
        local x2 = position[1] + radius
        local z2 = position[3] + radius
	
        local UnitsinRec = GetUnitsInRect( Rect(x1, z1, x2, z2) )
	
        -- Check for empty rectangle
        if not UnitsinRec then return false end
	
        local validUnits = { }
	
        for k, v in UnitsinRec do		
            if IsAlly(v:GetArmy(), unit:GetArmy()) and table.find(v:GetBlueprint().Categories, 'TELEPORTER') then
                local pos = v:GetPosition()
                local dist = math.sqrt( math.pow(pos[1] - position[1], 2) + math.pow(pos[3] - position[3], 2) )
			
                if v.TeleportReady and dist <= radius then
                    table.insert(validUnits, v)
                end
            end
        end

        return validUnits
    end,
}

AirStagingPlatformUnit = Class(StructureUnit) {

	OnCreate = function(self)

		StructureUnitOnCreate(self)

		self.EventCallbacks.OnTransportDetach = {}
		self.EventCallbacks.OnTransportAttach = {}

	end,

    -- this captures airpad enhancements
    OnCmdrUpgradeFinished = function(self)

        -- this detaches any stuck airunits that got 'caught' during enhancement
        for _,v in self:GetCargo() do
            v:DetachFrom()
        end

        StructureUnit.OnCmdrUpgradeFinished(self)
    end,    

	--- issued by the platform as units attach
    OnTransportAttach = function(self, attachBone, unit)
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.Sync.id.." Airpad OnTransportAttach to unit "..unit.Sync.id.." on tick "..GetGameTick() )
        end
        
		if not self.UnitStored then
			self.UnitStored = {}
		end
        
		self.UnitStored[unit.EntityID] = true
        
        unit.Attached = true

		StructureUnitOnTransportAttach(self, attachBone, unit)	
		
    end,

	--- issued by the platform as units detach
    OnTransportDetach = function(self, attachBone, unit)

        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.Sync.id.." Airpad OnTransportDetach unit "..unit.Sync.id.." on tick "..GetGameTick() )
        end
  
        unit.Attached = nil

        if self.UnitStored[unit.EntityID] then
            self.UnitStored[unit.EntityID] = nil
        end
      	
		StructureUnitOnTransportDetach(self, attachBone, unit)
		
    end,

}

ConcreteStructureUnit = Class(StructureUnit) {

    OnCreate = function(self)
        StructureUnitOnCreate(self)
        self:Destroy()
    end
}

WallStructureUnit = Class(StructureUnit) {

    OnCreate = function(self)

        EntityOnCreate(self)

		self.CacheLayer = moho.unit_methods.GetCurrentLayer(self)
		self.CachePosition = LOUDCOPY(moho.entity_methods.GetPosition(self))
        
        self.FxDamageAmount = {0,0,0}

        self.FxDamageAmount[1] = self.FxDamage1Amount or 1
        self.FxDamageAmount[2] = self.FxDamage2Amount or 1
        self.FxDamageAmount[3] = self.FxDamage3Amount or 1

        self.BuildEffectsBag = TrashBag()

        self.OnBeingBuiltEffectsBag = TrashBag()

        self:SetIntelRadius('Vision', 0)

		self.CanTakeDamage = true

		self.CanBeKilled = true

        self.Dead = false
		self.PlatoonHandle = false

        if GetAIBrain(self).CheatingAI then

			ApplyBuff( self, 'CheatALL')

        end

        self:OnCreated()
    end,


	-- all Wall sections follow this -- so it bypasses unit kills
	-- and a bunch of other not-needed work
    OnKilled = function(self, instigator, type, overkillRatio)

		self:DestroyAllDamageEffects()

        CreateScalableUnitExplosion( self, overkillRatio )

		PlayUnitSound( self, 'Destroyed')

		self:CreateWreckageProp( overkillRatio )

        self:Destroy()
		self = nil
    end,
}

EnergyCreationUnit = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        if self.AmbientEffects then

			local army = self.Army

            for k, v in EffectTemplate[self.AmbientEffects] do
                CreateAttachedEmitter(self, 0, army, v)
            end
        end

		UnitOnStopBeingBuilt(self,builder,layer)
    end,
}

EnergyStorageUnit = Class(StructureUnit) {}

FootprintDummyUnit = Class(StructureUnit) {
    OnAdjacentTo = function(self, AdjUnit, TriggerUnit)
        if not self.AdjacentData then self.AdjacentData = {} end
        LOUDINSERT(self.AdjacentData, AdjUnit)
        StructureUnit.OnAdjacentTo(self, AdjUnit, TriggerUnit)
    end,

    OnNotAdjacentTo = function(self, AdjUnit)
        if self.Parent then
            self.Parent.OnNotAdjacentTo(self.Parent, AdjUnit)
            AdjUnit:OnNotAdjacentTo(self.Parent)
            self.ForceDestroyAdjacentEffects({self.Parent, AdjUnit})
        end
        StructureUnit.OnNotAdjacentTo(self, AdjUnit)
    end,
}

MassCollectionUnit = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        StructureUnitOnStopBeingBuilt(self,builder,layer)
        
        self:SetMaintenanceConsumptionActive()
    end,

    OnStartBuild = function(self, unitbuilding, order)

        StructureUnitOnStartBuild(self, unitbuilding, order)

        self:AddCommandCap('RULEUCC_Stop')

        local massConsumption = self:GetConsumptionPerSecondMass()
        local massProduction = self:GetProductionPerSecondMass()

        self.UpgradeWatcher = self:ForkThread(self.WatchUpgradeConsumption, massConsumption, massProduction)
    end,

    OnStopBuild = function(self, unitbuilding, order)

        StructureUnitOnStopBuild(self, unitbuilding, order)

        self:RemoveCommandCap('RULEUCC_Stop')

        if self.UpgradeWatcher then

            KillThread(self.UpgradeWatcher)

            SetConsumptionPerSecondMass( self, 0 )

            SetProductionPerSecondMass( self, __blueprints[self.BlueprintID].Economy.ProductionPerSecondMass or 0)
        end
    end,

    -- band-aid on lack of multiple separate resource requests per unit...
    -- if mass econ is depleted, take all the mass generated and use it for the upgrade
    WatchUpgradeConsumption = function(self, massConsumption, massProduction)

        local aiBrain = GetAIBrain(self)

        local GetEconomyStored = moho.aibrain_methods.GetEconomyStored
		local GetResourceConsumed = moho.unit_methods.GetResourceConsumed
		local IsPaused = moho.unit_methods.IsPaused
		local WaitTicks = WaitTicks
        
        local resettonormal = true

        while true do
            
            -- if not paused 
            if not IsPaused(self) then

                -- if we dont get 100% of what we need --
                if GetResourceConsumed(self) != 1 then
                
                    -- flag a reset to normal when conditions normalize
                    resettonormal = true

                    -- if we are 100% out of energy
                    if GetEconomyStored(aiBrain, 'ENERGY') <= 1 then
                    
                        -- turn off both production and consumption
                        SetProductionPerSecondMass( self, 0 )    --massProduction)
                        SetConsumptionPerSecondMass( self, 0 )   --massConsumption)
                        
                    else
                    -- we must be out of mass then --
                    
                        local massprod = math.min(1, GetEconomyStored(aiBrain,'ENERGY')/ self:GetConsumptionPerSecondEnergy())
                    
                        -- if we had at least 1% we must have some of the mass 
                        if GetResourceConsumed(self) > .01 then
                        
                            -- consumption will be set to normal --
                            SetConsumptionPerSecondMass( self, massConsumption)
                            
                            -- BUT production will be set to % of energy required
                            SetProductionPerSecondMass( self, (massProduction * massprod ) )
                            
                        else
                            --  turn it off
                            SetConsumptionPerSecondMass( self, 0)
                        end
                    end
                else
                    if resettonormal then

                        -- resume normal production and consumption
                        SetConsumptionPerSecondMass( self, massConsumption)
                        SetProductionPerSecondMass( self, massProduction)
                        
                        resettonormal = false
                    end
                end
            else
                -- pausing just seems to leave things alone while upgrading?
                SetProductionPerSecondMass( self, massProduction )
            end

            WaitTicks(3)
        end
    end,
}

MassFabricationUnit = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        StructureUnitOnStopBeingBuilt(self,builder,layer)
        
        self:SetMaintenanceConsumptionActive()

        SetProductionActive( self, true)
        
        self.AIThread = self:ForkThread( MassFabricationUnit.MassFabThread )
    end,

    MassFabThread = function(unit)
    
        local aiBrain = GetAIBrain(unit)

        -- filter out the Paragon and humans --
        if aiBrain.BrainType == 'Human' or EntityCategoryContains(categories.EXPERIMENTAL, unit) then
            return
        end
	
        local massfabison = true
        
        local GetEconomyStoredRatio = moho.aibrain_methods.GetEconomyStoredRatio
        local GetEconomyTrend = moho.aibrain_methods.GetEconomyTrend
        
        local WaitTicks = WaitTicks
	
        WaitTicks(50)
    
        local EnergyStoredRatio, MassStoredRatio, EnergyTrend
	
        while not unit.Dead do
	
            EnergyStoredRatio = ((GetEconomyStoredRatio( aiBrain, 'ENERGY' )) * 100)
            MassStoredRatio = ((GetEconomyStoredRatio( aiBrain, 'MASS' )) * 100)
        
            EnergyTrend = GetEconomyTrend( aiBrain, 'ENERGY' ) * 10     -- all trend values are *10 to get actual values
		
            if (MassStoredRatio > 95 or (EnergyStoredRatio < 25 and EnergyTrend < 700)) and massfabison then
        
                massfabison = false
                unit:OnProductionPaused()
            
            elseif (MassStoredRatio <= 95 and (EnergyStoredRatio > 50 and EnergyTrend > 350)) and not massfabison then
        
                massfabison = true
                unit:OnProductionUnpaused()
            
            end

            WaitTicks(41)	-- check every 4 seconds
        end   
    end,
    
    OnConsumptionActive = function(self)

        self:SetMaintenanceConsumptionActive()

        SetProductionActive( self, true)
    end,

    OnConsumptionInActive = function(self)

        self:SetMaintenanceConsumptionInactive()

        SetProductionActive( self, false)
    end,
}

RadarUnit = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        StructureUnitOnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionActive()
    end,

    OnIntelDisabled = function(self,intel)

        StructureUnit.OnIntelDisabled(self,intel)

        self:DestroyIdleEffects()
    end,

    OnIntelEnabled = function(self,intel)

        StructureUnit.OnIntelEnabled(self,intel)

        self:CreateIdleEffects()
    end,
    
}

RadarJammerUnit = Class(StructureUnit) {

    -- Shut down intel while upgrading
    OnStartBuild = function(self, unitbuilding, order)

        StructureUnitOnStartBuild(self, unitbuilding, order)

        self:SetMaintenanceConsumptionInactive()
        self:DisableIntel('Jammer')
        self:DisableIntel('RadarStealthField')

    end,

    -- If we abort the upgrade, re-enable the intel
    OnStopBuild = function(self, unitBeingBuilt)

        StructureUnitOnStopBuild(self, unitBeingBuilt)

        self:SetMaintenanceConsumptionActive()
        self:EnableIntel('Jammer')
        self:EnableIntel('RadarStealthField')

    end,

    -- If we abort the upgrade, re-enable the intel
    OnFailedToBuild = function(self)

        StructureUnitOnStopBuild(self)

        self:SetMaintenanceConsumptionActive()
        self:EnableIntel('Jammer')
        self:EnableIntel('RadarStealthField')

    end,

    OnStopBeingBuilt = function(self,builder,layer)

        StructureUnitOnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionActive()

    end,

    OnIntelEnabled = function(self,intel)

        StructureUnit.OnIntelEnabled(self,intel)

        if (intel == 'Jammer' or intel == 'RadarStealthField') and self.IntelEffects and not self.IntelFxOn then

			self.IntelEffectsBag = {}

			self.CreateTerrainTypeEffects( self, self.IntelEffects, 'FXIdle',  self.CacheLayer, nil, 'IntelEffectsBag' )
            
			self.IntelFxOn = true

		end
        
    end,

    OnIntelDisabled = function(self,intel)

        StructureUnit.OnIntelDisabled(self,intel)
        
        if (intel == 'Jammer' or intel == 'RadarStealthField') and self.IntelEffectsBag then

            CleanupEffectBag(self,'IntelEffectsBag')

            self.IntelEffectsBag = nil

            self.IntelFxOn = nil
            
        end

    end,

}

SonarUnit = Class(StructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        StructureUnitOnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionActive()
    end,

    CreateIdleEffects = function(self)

        StructureUnit.CreateIdleEffects(self)

    end,

    DestroyIdleEffects = function(self)

        self.TimedSonarEffectsThread:Destroy()
        StructureUnit.DestroyIdleEffects(self)
    end,

}

ShieldStructureUnit = Class(StructureUnit) {

	UpgradingState = State(StructureUnit.UpgradingState) {

        Main = function(self)
            StructureUnit.UpgradingState.Main(self)
        end,

        OnFailedToBuild = function(self)
            StructureUnit.UpgradingState.OnFailedToBuild(self)
        end,
    }
}

TransportBeaconUnit = Class(StructureUnit) {

    FxTransportBeacon = {'/effects/emitters/red_beacon_light_01_emit.bp'},
    FxTransportBeaconScale = 0.5,

    -- invincibility!  (the only way to kill a transport beacon is to kill the transport unit generating it)
    OnDamage = function(self, instigator, amount, vector, damageType)
    end,

    OnCreate = function(self)
        StructureUnitOnCreate(self)
        self:SetCapturable(false)
        self:SetReclaimable(false)
    end,
}


WalkingLandUnit = Class(MobileUnit) {
   
    IdleAnim = false,
    DeathAnim = false,

    PlayCommanderWarpInEffect = function(self)

        self:HideBone(0, true)
        self:SetUnSelectable(true)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self:ForkThread(self.WarpInEffectThread)
    end,

    OnCmdrUpgradeFinished = function(self)
        self:DoUnitCallbacks('OnCmdrUpgradeFinished')
    end,

    OnCmdrUpgradeStart = function(self)
        self:DoUnitCallbacks('OnCmdrUpgradeStart')
    end,

    OnMotionHorzEventChange = function( self, new, old )

		if not self.Dead then

			MobileUnitOnMotionHorzEventChange(self, new, old)

			if ( old == 'Stopped' ) then

				local bpDisplay = __blueprints[self.BlueprintID].Display

				if bpDisplay.AnimationWalk then

					if (not self.Animator) then
						self.Animator = CreateAnimator(self, true)
					end

					PlayAnim( self.Animator, bpDisplay.AnimationWalk, true )
                    
					self.Animator:SetRate(bpDisplay.AnimationWalkRate or 1)

				end

			elseif ( new == 'Stopped' ) then

				if self.IdleAnim then

					if (not self.Animator) then
						self.Animator = CreateAnimator(self, true)
					end

					PlayAnim( self.Animator, self.IdleAnim, true)

				elseif not self.DeathAnim or not self.Dead then

					if self.Animator then
						self.Animator:Destroy()
					end

					self.Animator = nil
				end
			end
		end
    end,

	-- so that ACU and SCU get engy callbacks
	SetupEngineerCallbacks = function( eng, EM )
		ConstructionUnit.SetupEngineerCallbacks( eng, EM )
	end,

}

DirectionalWalkingLandUnit = Class(WalkingLandUnit) {

    OnMotionHorzEventChange = function( self, new, old )

        WalkingLandUnit.OnMotionHorzEventChange(self, new, old)

        if ( old == 'Stopped' ) and self.Animator then
            self.Animator:SetDirectionalAnim(true)
        end
    end,
}


SubUnit = Class(MobileUnit) {

    FxDamage1 = {EffectTemplate.DamageSparks01},
    FxDamage2 = {EffectTemplate.DamageSparks01},
    FxDamage3 = {EffectTemplate.DamageSparks01},

    PlayDestructionEffects = false,
    
    OnStopBeingBuilt = function(self,builder,layer)

        UnitOnStopBeingBuilt(self,builder,layer)
        
        self:SetTurnMult(0.4)

        self:SetMaintenanceConsumptionActive()
    end,

    OnKilled = function(self, instigator, type, overkillRatio)

        self:DestroyIdleEffects()

        if (self.CacheLayer == 'Water' or self.CacheLayer == 'Seabed' or self.CacheLayer == 'Sub') then

			self.SinkExplosionThread = self:ForkThread(self.ExplosionThread)
			self.Trash:Add(self.SinkExplosionThread)

			self.SinkThread = self:ForkThread(self.SinkingThread)
			self.Trash:Add(self.SinkThread)

		end

        MobileUnitOnKilled(self, instigator, type, overkillRatio)
    end,

    OnMotionHorzEventChange = function( self, new, old )

        if self.Dead then
            return
        end
    
        MobileUnitOnMotionHorzEventChange( self, new, old)
  
        if new == 'Cruise' then
			self:SetTurnMult(0.7)
        end

        if (new == 'Stopped' or new == 'Stopping') then
			self:SetTurnMult(0.5)
        end
        
        if new == 'TopSpeed' then
            self:SetTurnMult(1)
        end
    end,

    DeathThread = function(self, overkillRatio, instigator)
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." SubUnit DeathThread for "..__blueprints[self.BlueprintID].Description.." on tick "..GetGameTick() )
        end
  
        if self.DeathAnimManip then
			WaitFor(self.DeathAnimManip)
		end
		
        local army = self.Army
        local pos = GetPosition(self)

        local seafloor = GetTerrainHeight(pos[1], pos[3])

        if self.PlayAnimationDeath then

            local sinkcount = 0

            while self.DeathAnimManip and sinkcount < 20 do
                WaitTicks(10)
                sinkcount = sinkcount + 1
            end

		else

            self:ForkThread(function()

                local CreateEmitterAtBone = CreateEmitterAtBone
                local LOUDFLOOR = LOUDFLOOR

                local numBones = GetBoneCount(self)-1
                local rx, ry, rz = self:GetUnitSizes()
                local vol = rx * ry * rz
                
                local rs, randBone

                local i = 1

                while i < 12 do

                    rx, ry, rz = GetRandomOffset( self, 0.25 )
					rs = Random(vol * 0.5, vol*2) / (vol*2)
                    
                    randBone = LOUDFLOOR(Random() * (numBones + 1))

                    CreateEmitterAtBone( self, randBone, army, '/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):ScaleEmitter(rs):OffsetEmitter(rx, ry, rz)

                    CreateEmitterAtBone( self, randBone, army, '/effects/emitters/destruction_underwater_sinking_wash_01_emit.bp'):ScaleEmitter(rx * 0.33):OffsetEmitter(rx, ry, rz)

                    CreateEmitterAtBone( self, 0, army, '/effects/emitters/destruction_underwater_sinking_wash_01_emit.bp'):ScaleEmitter(rx* 0.5):OffsetEmitter(rx, ry, rz)

                    WaitTicks( 4 + i + (Random(1,3)*6) )
                    
                    i = i + 3
                end
            end)


            local slider = CreateSlider(self, 0, 0, -(pos[2]-seafloor)*10, 0, 4)

			self.Trash:Add(slider)

            WaitFor(slider)

            slider:Destroy()
        end

		if self.DeathAnimManip then
			self.DeathAnimManip:Destroy()
			self.DeathAnimManip = nil
		end

        self:DestroyAllDamageEffects()

        -- create wreckage but no surface effects
		self:CreateWreckageProp( overkillRatio, nil, true )

        self:Destroy()
    end,

    ExplosionThread = function(self)

        local army = self.Army

        local d = 0

        local rx, ry, rz = self:GetUnitSizes()
        local vol = rx * ry * rz

        local volmin = 1.5
        local volmax = 12

        local scalemin = 1
        local scalemax = 2.5

        local t = (vol-volmin)/(volmax-volmin)
        local rs = scalemin + (t * (scalemax-scalemin))

        if rs < scalemin then
            rs = scalemin
        elseif rs > scalemax then
            rs = scalemax
        end

		local CreateEmitterAtEntity = CreateEmitterAtEntity
		local Random = Random
		local WaitTicks = coroutine.yield

        CreateEmitterAtEntity(self,army,'/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):ScaleEmitter(rs)
        CreateEmitterAtEntity(self,army,'/effects/emitters/destruction_underwater_explosion_splash_02_emit.bp'):ScaleEmitter(rs)

        for i = 1, LOUDFLOOR(Random(2,4)) do

            rx, ry, rz = GetRandomOffset( self, 1)
            rs = Random(vol * 0.5, vol*2) / (vol*2)

            CreateEmitterAtEntity(self,army,'/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):ScaleEmitter(rs):OffsetEmitter(rx, ry -i/2, rz)
            WaitTicks(2)
            
            CreateEmitterAtEntity(self,army,'/effects/emitters/destruction_underwater_explosion_splash_01_emit.bp'):ScaleEmitter(rs):OffsetEmitter(rx, ry -i/2, rz)
            WaitTicks(5 + Random( 5, 12 ) + d)
        end
    end,

    SinkingThread = function(self)

        local army = self.Army

        local rx, ry, rz = self:GetUnitSizes()
        local vol = rx * ry * rz

		local CreateAttachedEmitter = CreateAttachedEmitter
		local Random = Random
        
        local LeftFrontWakeBone = self.LeftFrontWakeBone
        local RightFrontWakeBone = self.RightFrontWakeBone
        
        local rs

        for i = 1, 8 do

            rx, ry, rz = GetRandomOffset( self, 0.5)            

            rs = Random(vol*0.5, vol*2) / (vol*2)

            if i == 1 then

                CreateAttachedEmitter(self, -1, army, '/effects/emitters/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
                WaitTicks(2)
                
                CreateAttachedEmitter(self, LeftFrontWakeBone, army, '/effects/emitters/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
                WaitTicks(2)
                
                CreateAttachedEmitter(self, RightFrontWakeBone,army, '/effects/emitters/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)
            else

                CreateAttachedEmitter(self,-1,army,'/effects/emitters/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, -i/2, rz):ScaleEmitter(rs)
            end

            WaitTicks( 6 + i + Random(4,6) )
        end
        
    end,
}

SeaUnit = Class(MobileUnit) {

    PlayDestructionEffects = false,
    
    OnStopBeingBuilt = function(self,builder,layer)

        UnitOnStopBeingBuilt(self,builder,layer)
        
        self:SetTurnMult(0.4)

        self:SetMaintenanceConsumptionActive()
    end,

    -- by default, just destroy us when we are killed.
    OnKilled = function(self, instigator, type, overkillRatio)

        self:DestroyIdleEffects()

        if (self.CacheLayer == 'Water' or self.CacheLayer == 'Seabed' or self.CacheLayer == 'Sub') then

            self.SinkExplosionThread = self:ForkThread(self.ExplosionThread)
			TrashAdd( self.Trash, self.SinkExplosionThread )

            self.SinkThread = self:ForkThread(self.SinkingThread)
			TrashAdd( self.Trash, self.SinkThread )
        end

        MobileUnitOnKilled(self, instigator, type, overkillRatio)
    end,

    -- naval units don't get full turn rate until at max speed
    OnMotionHorzEventChange = function( self, new, old )

        if self.Dead then
            return
        end
    
        MobileUnitOnMotionHorzEventChange( self, new, old)
  
        if new == 'Cruise' then
			self:SetTurnMult(0.7)
        end

        if (new == 'Stopped' or new == 'Stopping') then
			self:SetTurnMult(0.4)
        end
        
        if new == 'TopSpeed' then
            self:SetTurnMult(1)
        end
    end,

    DeathThread = function(self, overkillRatio, instigator)
    
        if ScenarioInfo.UnitDialog then
            LOG("*AI DEBUG UNIT "..GetAIBrain(self).Nickname.." "..self.EntityID.." SeaUnit DeathThread for "..__blueprints[self.BlueprintID].Description.." on tick "..GetGameTick() )
        end
  
        if self.DeathAnimManip then
			WaitFor(self.DeathAnimManip)
		end

        local bp = __blueprints[self.BlueprintID]
        local army = self.Army

        self:DestroyAllDamageEffects()

        if bp.Display.AnimationDeath then

            local sinkcount = 0

            while self.DeathAnimManip and sinkcount < 20 do

                WaitTicks(6)
                sinkcount = sinkcount + 1

            end

        else  -- if no death animation use slider

            local pos = GetPosition(self)

            local seafloor = GetTerrainHeight(pos[1], pos[3])

            local slider = CreateSlider(self, 0, 0, (seafloor-pos[2])*10, 0, 4)

			TrashAdd( self.Trash, slider )

            self:ForkThread(function()

                local CreateEmitterAtBone = CreateEmitterAtBone
                local LOUDFLOOR = LOUDFLOOR

                local numBones = GetBoneCount(self) - 1
                local sx, ry, rz = self:GetUnitSizes()
                local vol = sx * ry * rz
                
                local rs, rx, randBone

                rx, ry, rz = GetRandomOffset( self, 0.25)
				rs = Random(vol * 0.5, vol*2) / (vol*2)

                randBone = LOUDFLOOR(Random() * (numBones + 1))

                CreateEmitterAtBone( self, randBone, army, '/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):ScaleEmitter(rs):OffsetEmitter(rx, ry, rz)

                CreateEmitterAtBone( self, randBone, army, '/effects/emitters/destruction_underwater_sinking_wash_01_emit.bp'):ScaleEmitter(sx * 0.33):OffsetEmitter(rx, ry, rz)

            end)

            WaitFor(slider)

            slider:Destroy()

        end

		if self.DeathAnimManip then
			self.DeathAnimManip:Destroy()
			self.DeathAnimManip = nil
		end

        -- create wreckage prop but bypass final surface debris
        self:CreateWreckageProp( overkillRatio, nil, true )

        self:Destroy()

    end,

    ExplosionThread = function(self)

        local army = self.Army

        local d = 0

        local rx, ry, rz = self:GetUnitSizes()
        local vol = rx * ry * rz

        local volmin = 1.5
        local volmax = 12

        local scalemin = 1
        local scalemax = 2.5

        local t = (vol-volmin)/(volmax-volmin)
        local rs = scalemin + (t * (scalemax-scalemin))

        if rs < scalemin then
            rs = scalemin
        elseif rs > scalemax then
            rs = scalemax
        end
        
        local numBones = GetBoneCount(self) - 1

		local CreateEmitterAtEntity = CreateEmitterAtEntity
		local Random = Random
		local WaitTicks = coroutine.yield


        CreateEmitterAtEntity(self,army,'/effects/emitters/destruction_underwater_explosion_splash_02_emit.bp'):ScaleEmitter(rs*.66)
        
        for i = 1, LOUDFLOOR(Random(4,6)) do

            rx, ry, rz = GetRandomOffset( self, 1)
            rs = Random(vol * 0.5, vol*2) / (vol*2)

            CreateEmitterAtEntity(self,army,'/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):OffsetEmitter( rx, -i/2, rz):ScaleEmitter(rs/i)
        
            WaitTicks( 2 + Random(1,2) )

            CreateDefaultHitExplosionAtBone( self, LOUDFLOOR(Random() * (numBones + 1)), rs/i )  

            WaitTicks( 6 + Random(5,10) )
        end

        self:DestroyAllDamageEffects()
    end,

    SinkingThread = function(self)

        local army = self.Army

        local rx, ry, rz = self:GetUnitSizes()

        local vol = rx * ry * rz


		local CreateAttachedEmitter = CreateAttachedEmitter
		local Random = Random
        
        local LeftFrontWakeBone = self.LeftFrontWakeBone
        local RightFrontWakeBone = self.RightFrontWakeBone
        
        local rs

        for i = 1, 8 do

            rx, ry, rz = GetRandomOffset( self, 0.5)            

            rs = Random(vol*0.5, vol*2) / (vol*2)

            if i == 1 then

                CreateAttachedEmitter(self, -1, army, '/effects/emitters/destruction_water_sinking_ripples_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                WaitTicks(2)
                
                CreateAttachedEmitter(self, LeftFrontWakeBone, army, '/effects/emitters/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

                WaitTicks(2)
                
                CreateAttachedEmitter(self, RightFrontWakeBone,army, '/effects/emitters/destruction_water_sinking_wash_01_emit.bp'):OffsetEmitter(rx, 0, rz):ScaleEmitter(rs)

            else

                CreateAttachedEmitter(self,-1,army,'/effects/emitters/destruction_underwater_sinking_wash_01_emit.bp'):OffsetEmitter(rx, -i/2, rz):ScaleEmitter(rs/i)

            end

            WaitTicks( 6 + i + Random(4,6) )
        end

    end,
}

AirUnit = Class(MobileUnit) {

    OnCreate = function(self)

        UnitOnCreate(self)

        self:AddPingPong()

		self.EventCallbacks.OnStartRefueling = {}
		self.EventCallbacks.OnRunOutOfFuel = {}
		self.EventCallbacks.OnGotFuel = {}

		self.HasFuel = true
        self.RefitThread = nil

        local aiBrain = GetAIBrain(self)

        if aiBrain.BrainType == 'AI' and aiBrain.Nickname != 'civilian' then
            
            local LOUDENTITY = EntityCategoryContains

            if LOUDENTITY( AIRUNITS, self) then
		
                -- all AIR units (except true Transports) will get these callbacks to assist with Airpad functions
                if not LOUDENTITY( TRANSPORTS, self) then

                    local ProcessDamagedAirUnit = function( self, newHP, oldHP )
                        
                        if not self.InRefit then
	
                            -- added check for RTP callback (which is intended for transports but UEF gunships sometimes get it)
                            -- to bypass this if the unit is in the transport pool --
                            if (newHP < oldHP and newHP < 0.5) and not self.EventCallbacks['OnTransportDetach'] then

                                ProcessAirUnits( self, GetAIBrain(self) )
                            end
                        end
                    end

                    self:AddUnitCallback( ProcessDamagedAirUnit, 'OnHealthChanged')
				
                    local ProcessFuelOutAirUnit = function( self )
				
                        if not self.InRefit then
                            
                            -- this flag only gets turned on after this executes
                            -- and is turned back on only when the unit gets fuel - so we avoid multiple executions
                            -- and we don't process this if it's a transport pool unit --
                            if not self.EventCallbacks['OnTransportDetach'] then

                                ProcessAirUnits( self, GetAIBrain(self) )
                            end
                        end
                    end

                    self:AddUnitCallback( ProcessFuelOutAirUnit, 'OnRunOutOfFuel')
                else

                    self:ForkThread( AssignTransportToPool, aiBrain )
                end
            end
        end        
    end,

    ActiveState = State {

        Main = function(self)
			self:SetActiveConsumptionActive()
        end,

    },

    IdleState = State {

        Main = function(self)
			self:SetActiveConsumptionInactive()
        end,

    },

    AddPingPong = function(self)

        local bp = __blueprints[self.BlueprintID].Display

        if bp.PingPongScroller then

            bp = bp.PingPongScroller

            if bp.Ping1 and bp.Ping1Speed and bp.Pong1 and bp.Pong1Speed and bp.Ping2 and bp.Ping2Speed
                and bp.Pong2 and bp.Pong2Speed then

                self:AddPingPongScroller(bp.Ping1, bp.Ping1Speed, bp.Pong1, bp.Pong1Speed, bp.Ping2, bp.Ping2Speed, bp.Pong2, bp.Pong2Speed)

            end

        end

    end,

	OnLayerChange = function (self, new, old )

		MobileUnitOnLayerChange( self, new, old )

        local VDist2Sq = VDist2Sq
		local vis = __blueprints[self.BlueprintID].Intel.VisionRadius or 2

		if new == 'Land' then
		
			-- if current vision is mostly normal then
			-- turn it down to 40% of current vision
			if self:GetIntelRadius('Vision') > (vis * 0.75) then
			
				self:SetIntelRadius('Vision', self:GetIntelRadius('Vision') * 0.4)
				
			end

			self:DisableIntel('Sonar')
			self:DisableIntel('Radar')
			self:DisableIntel('Omni')			

			if not EntityCategoryContains(categories.TRANSPORTFOCUS, self) then
			
				local brain = GetAIBrain(self)
				
				-- sometimes AI units will 'wander' away and land beyond the control of a base
				-- this will get them back to a base position
				if brain.BrainType == 'AI' and brain.Nickname != 'civilian' then
			
					local beyondbase = true
	
					-- loop thru his bases
					for _,base in brain.BuilderManagers do
				
						local unitpos = self:GetPosition()
					
						-- if position is within the radius then return false (avoid this position)
						if VDist2Sq(base.Position[1], base.Position[3], unitpos[1], unitpos[3]) < (base.Radius * base.Radius) then
					
							beyondbase = false

						end

					end
				
					if beyondbase then
						ForkThread( ReturnTransportsToPool, brain, {self}, true )
					end

				end
			
			end

		end

		if new == 'Air' then
		
			-- if current vision radius is less than standard blueprint value
			-- then it must have been turned down by this previously - turn it back up
			if self:GetIntelRadius('Vision') <= (vis * 0.75) then

				self:SetIntelRadius('Vision', self:GetIntelRadius('Vision') * 2.5)
				
			end

			self:EnableIntel('Sonar')
			self:EnableIntel('Radar')
			self:EnableIntel('Omni')
		end
		
		
		
	end,

    OnMotionHorzEventChange = function( self, new, old )
        
        --LOG("*AI DEBUG AirUnit Horiz change from "..repr(old).." to "..repr(new) )
    
        MobileUnitOnMotionHorzEventChange( self, new, old)
        
    end,

    OnMotionVertEventChange = function( self, new, old )

		if not self.Dead then
        
            --LOG("*AI DEBUG AirUnit Verti change from "..repr(old).." to "..repr(new) )

			if (new == 'Down') then

                if not HasBuff( self,'Landing') then
                    ApplyBuff(self,'Landing')
                end
  
				PlayUnitSound(self,'Landing')

			elseif (new == 'Bottom') or (new == 'Hover') then

				PlayUnitSound(self,'Landed')

			elseif (new == 'Up' or ( new == 'Top' and ( old == 'Down' or old == 'Bottom' ))) then

				PlayUnitSound(self,'TakeOff')

			end

			if (new == 'Bottom') then

				ChangeState( self, self.IdleState)

			elseif (new == 'Up' or  new == 'Top') and old == 'Bottom' then

				ChangeState( self, self.ActiveState)
			end

		end

		MobileUnitOnMotionVertEventChange( self, new, old )

    end,

	--- fires when the unit fuel falls below the trigger threshold ?
    OnRunOutOfFuel = function(self)
        
        --LOG("*AI DEBUG AirUnit OnRunOutOfFuel")

        self:DoUnitCallbacks('OnRunOutOfFuel')

        if not HasBuff( self,'OutOfFuel') then
            ApplyBuff(self,'OutOfFuel')
        end
        
		if self.TopSpeedEffectsBag then
			self:DestroyTopSpeedEffects()
		end

        self.HasFuel = false
    end,

	--- fires when the unit fuel is above the trigger threshold ?
    OnGotFuel = function(self)

		if HasBuff( self,'OutOfFuel') then
            RemoveBuff(self,'OutOfFuel')
        end
        
        --LOG("*AI DEBUG AirUnit OnGotFuel")

		self.HasFuel = true
    end,

	--- this fires when the unit attaches to an airpad
    OnStartRefueling = function(self)
        
        --LOG("*AI DEBUG AirUnit OnStartRefueling")

        PlayUnitSound(self,'Refueling')
		
        self:DoUnitCallbacks('OnStartRefueling')
    end,

    OnHealthChanged = function(self, new, old)

		if not self.Dead and new > 0 then
        
            local Fuel = self.HasFuel
		
			-- Health values come in at fixed 25% intervals
			if new < old then

				-- so at 50% damage air performance drops
				if old == 0.75 then
                
                    if not HasBuff( self, 'HeavyDamageAir' ) then 
                        ApplyBuff( self, 'HeavyDamageAir' )
                    end

				-- and below 25% it drops even more
				elseif old <= 0.5 then
                
                    if not HasBuff( self, 'SevereDamageAir' ) then 
                        ApplyBuff( self, 'SevereDamageAir' )
                    end
					
				end
				
			else

				-- at 25% move performance back up 
				if new == 0.25 then
                
                    if HasBuff( self, 'SevereDamageAir' ) then 
                        RemoveBuff( self, 'SevereDamageAir' )
                    end
					
				-- at 50% restore full performance
				elseif new >= 0.5 then
                
                    if HasBuff( self, 'HeavyDamageAir' ) then 
                        RemoveBuff( self, 'HeavyDamageAir' )
                    end

				end
			end
		end
		
		UnitOnHealthChanged(self, new, old)
    end,	
	
    OnImpact = function(self, with, other)

        local army = self.Army
        local bp = __blueprints[self.BlueprintID]

        if ScenarioInfo.UnitDialog then        
            LOG("*AI DEBUG UNIT "..self.EntityID.." AIR OnImpact with "..repr(with))
        end

        local i = 1

        for i,v in bp.Weapon do

            if(bp.Weapon[i].Label == 'DeathImpact') then
                DamageArea(self, GetPosition(self), bp.Weapon[i].DamageRadius, bp.Weapon[i].Damage, bp.Weapon[i].DamageType, bp.Weapon[i].DamageFriendly)
                break
            end

        end

		-- if the air unit impacts water and has seabed wreckage then animate the sinking
        if with == 'Water' and (bp.Wreckage.WreckageLayers['Seabed'] or bp.Wreckage.WreckageLayers['Water']) then

            PlayUnitSound(self,'AirUnitWaterImpact')

            CreateEffects( self, army, EffectTemplate.DefaultProjectileWaterImpact )

			self:ForkThread( self.SinkIntoWaterAfterDeath, self.OverKillRatio)
            
        else
            if not self.DeathBounce then
                self.DeathBounce = 1
				
				if with == 'Terrain' then
					self.CacheLayer = 'Land'
				end

                self:ForkThread(self.DeathThread, self.OverKillRatio or 0 )
            end
        end
        
    end,

	SinkIntoWaterAfterDeath = function(self, overkillRatio)

		local sx, sy, sz = self:GetUnitSizes()
		local vol = sx * sy * sz

		local army = self.Army
		local pos = GetPosition(self)

		local seafloor = GetTerrainHeight(pos[1], pos[3])
        
		local numBones = GetBoneCount(self) - 1

        self:DestroyAllDamageEffects()

		-- this thread will create effects until the slider reaches its goal and then destroys it
		self:ForkThread(function()

			local rx, ry, rz = GetRandomOffset( self, 1 )

			local rs = Random(vol, vol*2) / (vol)

			local i = 1
            
            local randBone

			CreateEmitterAtBone( self, 0, army, '/effects/emitters/destruction_underwater_sinking_wash_01_emit.bp'):ScaleEmitter(sx * 0.5):OffsetEmitter(rx, ry - i, rz)

			while true do

				WaitTicks( 5 + i )

				randBone = LOUDFLOOR(Random() * (numBones + 1))

				CreateEmitterAtBone( self, randBone, army, '/effects/emitters/destruction_underwater_explosion_flash_01_emit.bp'):ScaleEmitter(rs):OffsetEmitter(rx, ry - i, rz)
                
                WaitTicks( 3 + i )

                randBone = LOUDFLOOR(Random() * (numBones + 1))

				CreateEmitterAtBone( self, randBone, army, '/effects/emitters/destruction_underwater_sinking_wash_01_emit.bp'):ScaleEmitter((sx * 0.5)/i):OffsetEmitter(rx, ry - i, rz)

				i = i + 1
			end
		end)

		local orientation = self:GetOrientation()

        orientation[1] = 0
        orientation[3] = 0

		self:SetOrientation( orientation, true )

		local slider = CreateSlider(self, 0, 0, (seafloor-pos[2])*10, 0, 4 )

		self.Trash:Add(slider)

		WaitFor(slider)

		slider:Destroy()

        self:CreateWreckageProp(overkillRatio, nil, true)
        
		self:Destroy()
	end,

    CreateUnitAirDestructionEffects = function( self, scale )

        if ScenarioInfo.UnitDialog then    
            LOG("*AI DEBUG UNIT "..self.EntityID.."AIR Create DestructionEffects for "..self.BlueprintID)
        end

        CreateDefaultHitExplosion( self, GetAverageBoundingXZRadius(self))
        CreateDebrisProjectiles(self, GetAverageBoundingXYZRadius(self), {self:GetUnitSizes()})
    end,

    -- ON KILLED: THIS FUNCTION PLAYS WHEN THE UNIT TAKES A MORTAL HIT.  IT PLAYS ALL THE DEFAULT DEATH EFFECT
    -- IT ALSO SPAWNS THE WRECKAGE BASED UPON HOW MUCH IT WAS OVERKILLED. UNIT WILL SPIN OUT OF CONTROL TOWARDS GROUND
	-- The OnImpact event will handle the final destruction
    OnKilled = function(self, instigator, deathtype, overkillRatio)

        if ScenarioInfo.UnitDialog then    
            LOG("*AI DEBUG UNIT "..self.EntityID.." AIR OnKilled for "..self.BlueprintID)
        end
        
		-- 65% of the time aircraft will just disintegrate, experimentals ALWAYS crash to ground
		-- this is the normal (air crash to ground) path
		
		-- NOTE: how we bypass the UNIT.OnKilled and let the OnImpact event handle the death
		-- this causes a minor issue where a unit can be Dead but not Destroyed
        if self.CacheLayer == 'Air' and ( Random() > 0.65 or EntityCategoryContains(categories.EXPERIMENTAL, self)) then

            self.CreateUnitAirDestructionEffects( self, 1.0 )

			if self.TopSpeedEffectsBag then
				self:DestroyTopSpeedEffects()
			end

			if self.BeamExhaustEffectsBag then
			    self:DestroyBeamExhaust()
			end

			if instigator and IsUnit(instigator) then
				instigator:ForkThread(Unit.OnKilledUnit, self)
			end

            self.OverKillRatio = overkillRatio

            PlayUnitSound(self,'Killed')

            self:DoUnitCallbacks('OnKilled')

			self:DisableShield()
			self:DisableUnitIntel()
            
            self.Impact = true
            
            MobileUnitOnKilled(self, instigator, deathtype, overkillRatio)
            
		-- this is the disintegrate path -- always used when air units are on the ground
        else

            self.DeathBounce = 1
			
			self.PlayDeathAnimation = false
			self.DeathWeaponEnabled = false
			
			MobileUnitOnKilled(self, instigator, deathtype, overkillRatio)
        end

    end,

}

ConstructionUnit = Class(MobileUnit) {

	-- this used to be part of the platoon file and was executed every time engy got a build order
	-- now it runs only when the engy is added to an Engineer Manager
    SetupEngineerCallbacks = function( eng, EM )

        if eng and (not eng.Dead) then

			local EngineerBuildDone = function( unit, finishedUnit )

				if unit.PlatoonHandle and unit.PlatoonHandle.PlanName then

					-- we do this to insure that the constructed unit gets acknowledged
					-- since sometimes the original engineer dies and the unit is completed
					-- by an engineer in assist mode that didn't issue the original build order
					if not finishedUnit.ConstructionCompleted then
						EM:UnitConstructionFinished( eng, finishedUnit )
					end

					if unit.IssuedBuildCommand and GetFractionComplete(finishedUnit) == 1 then

						if not unit.NotBuildingThread then

							if LOUDFIND(unit.PlatoonHandle.PlanName, 'EngineerBuild') then
								unit.PlatoonHandle:ProcessBuildCommand( unit, true)
							end
						end
					end
				end
			end

			local EngineerCaptureDone = function( unit )

				if unit.PlatoonHandle and unit.PlatoonHandle.PlanName then

					if LOUDFIND(unit.PlatoonHandle.PlanName, 'EngineerBuild') then
						unit.PlatoonHandle:ProcessBuildCommand( unit, false)
					end

				end

			end

			local EngineerFailedCapture = function( unit )

				if unit.PlatoonHandle and unit.PlatoonHandle.PlanName then

					if LOUDFIND(unit.PlatoonHandle.PlanName, 'EngineerBuild') then

						unit.PlatoonHandle:ProcessBuildCommand( unit, false )

					end

				end

			end

			local EngineerFailedToBuild = function( unit )

				if unit.PlatoonHandle and unit.PlatoonHandle.PlanName then

					if not unit.NotBuildingThread then

						if unit.IssuedBuildCommand then

							if LOUDFIND(unit.PlatoonHandle.PlanName, 'EngineerBuild') then
								unit.PlatoonHandle:ProcessBuildCommand( unit, true)
							end

						end

					end

				end

			end

			local EngineerStartBeingCaptured = function( unit )

				if unit.PlatoonHandle then

					local self = unit.PlatoonHandle

					self:SetAIPlan('ReturnToBaseAI', self:GetBrain())
				end
			end

			eng:AddOnUnitBuiltCallback( EngineerBuildDone, categories.ALLUNITS )
            
            eng:AddOnStartBuildCallback( EM.UnitConstructionStarted, categories.FACTORY * categories.STRUCTURE - categories.EXPERIMENTAL )

			eng:AddUnitCallback( EngineerCaptureDone, 'OnStopCapture')
			eng:AddUnitCallback( EngineerFailedCapture, 'OnFailedCapture')
			eng:AddUnitCallback( EngineerFailedToBuild, 'OnFailedToBuild')
			eng:AddUnitCallback( EngineerStartBeingCaptured, 'OnStartBeingCaptured' )
        end

    end,

    OnCreate = function(self)

        UnitOnCreate(self)

        if __blueprints[self.BlueprintID].General.BuildBones then
            self:SetupBuildBones()
        end

        if __blueprints[self.BlueprintID].Display.AnimationBuild then
        
            self.BuildingOpenAnim = __blueprints[self.BlueprintID].Display.AnimationBuild
        end

        if self.BuildingOpenAnim then

            self.BuildingOpenAnimManip = CreateAnimator(self)
            
            PlayAnim( self.BuildingOpenAnimManip, self.BuildingOpenAnim ):SetRate(0)

			TrashAdd( self.Trash, self.BuildingOpenAnimManip )

			self.BuildingOpenAnim = nil

            if self.BuildArmManipulator then

                self.BuildArmManipulator:Disable()

            end
        end

        self.BuildingUnit = false
    end,

    OnPaused = function(self)

        --self:StopUnitAmbientSound( 'ConstructLoop' )
        Unit.OnPaused(self)

        if self.BuildingUnit then
            Unit.StopBuildingEffects(self, self.UnitBeingBuilt )
        end
    end,

    OnUnpaused = function(self)

        if self.BuildingUnit then

            --self:PlayUnitAmbientSound( 'ConstructLoop' )

            Unit.StartBuildingEffects(self, self.UnitBeingBuilt, self.UnitBuildOrder)

        end

        Unit.OnUnpaused(self)
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )

        UnitOnStartBuild(self,unitBeingBuilt, order)

        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true

		if order == 'Upgrade' then

			if unitBeingBuilt.BlueprintID == __blueprints[self.BlueprintID].General.UpgradesTo then

				self.Upgrading = true
				self.BuildingUnit = false
			end
        end
    end,

    OnStopBuild = function(self, unitBeingBuilt)

        UnitOnStopBuild(self,unitBeingBuilt)

        if self.CurrentBuildOrder == 'MobileBuild' then  -- this prevents false positives by assisted enhancing

            if self.OnStopBuildWasRun then

                if unitBeingBuilt and not BeenDestroyed(unitBeingBuilt) then

                    unitBeingBuilt:Destroy()
                end
            else

                self.OnStopBuildWasRun = true

                self:ForkThread( function(self) WaitTicks(2) self.OnStopBuildWasRun = nil end )
            end
        end

        if self.Upgrading then

            NotifyUpgrade(self,unitBeingBuilt)

            self:Destroy()
        end

        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil

        if self.BuildingOpenAnimManip and self.BuildArmManipulator then

            self.StoppedBuilding = true

        elseif self.BuildingOpenAnimManip then

            self.BuildingOpenAnimManip:SetRate(-1)
        end

        self.BuildingUnit = false
    end,

    WaitForBuildAnimation = function(self, enable)

        if self.BuildArmManipulator then

            WaitFor(self.BuildingOpenAnimManip)

            if (enable) then

                self.BuildArmManipulator:Enable()
            end
        end
    end,

    OnPrepareArmToBuild = function(self)

        if self.BuildingOpenAnimManip then

            self.BuildingOpenAnimManip:SetRate( __blueprints[self.BlueprintID].Display.AnimationBuildRate or 1 )

            if self.BuildArmManipulator then

                self.StoppedBuilding = false

                self:ForkThread( self.WaitForBuildAnimation, true )
            end
        end
    end,

    OnStopBuilderTracking = function(self)

        if self.StoppedBuilding then

            self.StoppedBuilding = false

            self.BuildArmManipulator:Disable()

            self.BuildingOpenAnimManip:SetRate(-(__blueprints[self.BlueprintID].Display.AnimationBuildRate or 1))
        end
    end,
}

---------------------------------
local MissileDetectorRadius = {}
---------------------------------
BaseDirectionalAntiMissileFlare = Class() {

    CreateMissileDetector = function(self)

        local bp = __blueprints[self.BlueprintID]
        local MDbp = bp.Defense.MissileDetector
		
		-- The effectiveness of the anti-missile system is highly dependent upon the 
		-- size of the detector - since in the tick between detection and impact the
		-- missile can pass thru the radius of the detector and still impact the 
		-- intended unit
		-- Therefore - in order to insure a certain level of effectiveness against
		-- SAM missiles (which can have a speed of 40 or more) we'll make the minimum
		-- radius somewhere around 4

        if not MissileDetectorRadius[bp.BlueprintId] and MDbp then
		
            MissileDetectorRadius[bp.BlueprintId] = 1 + math.sqrt(math.pow(VDist3(self:GetPosition(),self:GetPosition(MDbp.AttachBone)),2) + math.pow(bp.SizeSphere, 2))
            --LOG("Missile detector radius for " .. bp.BlueprintId .." set to "..MissileDetectorRadius[bp.BlueprintId])
			
        elseif not MissileDetectorRadius and not MDbp then
		
            MissileDetectorRadius[bp.BlueprintId] = 4
            WARN("Missile Detector data not set up correctly - default to 3.")
			
        end
	
		local MissileDetector = import('/lua/defaultantiprojectile.lua').MissileDetector
	
        self.Trash:Add(MissileDetector {
            Owner = self,
            Radius = MissileDetectorRadius[bp.BlueprintId],
            AttachBone = MDbp.AttachBone,
        })
    end,

}

-- Used primarily by SAB5401, but also mines,
-- for tracking adjacency and making and breaking path blocking.
FootprintDummyUnit = Class(StructureUnit) {

    OnAdjacentTo = function(self, AdjUnit, TriggerUnit)
        if not self.AdjacentData then self.AdjacentData = {} end
        table.insert(self.AdjacentData, AdjUnit)
        StructureUnit.OnAdjacentTo(self, AdjUnit, TriggerUnit)
    end,

    OnNotAdjacentTo = function(self, AdjUnit)

        if self.Parent then
            self.Parent.OnNotAdjacentTo(self.Parent, AdjUnit)
            AdjUnit:OnNotAdjacentTo(self.Parent)
            self.ForceDestroyAdjacentEffects({self.Parent, AdjUnit})
        end

        StructureUnit.OnNotAdjacentTo(self, AdjUnit)
    end,
}

MineStructureUnit = Class(StructureUnit) {

    Weapons = {

        Suicide = Class(import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon) {
        
            FxTrailScale = 0.3,

            FxDeathLand     = EffectTemplate.DefaultHitExplosion01,
            FxDeathSeabed   = EffectTemplate.DefaultProjectileWaterImpact,
            FxDeathWater    = EffectTemplate.SRifterArtilleryWaterHit,
            
            OnWeaponFired = function(self)

                local army      = self.unit.Army
                local bp        = self.bp
                local currlayer = self.unit.CacheLayer
                local radius    = bp.DamageRadius

                -- Do explosion effects
                local FxDeath = {
                    Land    = self.FxDeathLand,
                    Water   = self.FxDeathWater,
                    Seabed  = table.cat(self.FxDeathSeabed, self.FxDeathLand),
                }

                if ScenarioInfo.ProjectileDialog then
                    LOG("*AI DEBUG SuicideWeapon OnWeaponFired "..repr(bp.Label).." layer is  "..repr(currlayer).." at "..GetGameTick() )
                    LOG("*AI DEBUG SuidideWeapon FxDeathLand is "..repr(FxDeath.Land))
                end
                
                CreateBoneEffects( self.unit, -2, army, FxDeath[currlayer] )

                -- Do decal splats
                if not self.SplatTexture then
                    import('defaultexplosions.lua').CreateScorchMarkSplat( self.unit, bp.DamageRadius * 0.5, army)
                else
                    if self.SplatTexture.Albedo then                                                                                                                                                                                    --LOD          Lifetime
                        CreateDecal( self.unit.CachePosition, Random()*6.28, (self.SplatTexture.Albedo[1] or self.SplatTexture.Albedo), '', 'Albedo', radius * (self.SplatTexture.Albedo[2] or 4), radius * (self.SplatTexture.Albedo[2] or 4), radius * 60, bp.Damage * 15, army )
                    end
                    if self.SplatTexture.AlphaNormals then
                        CreateDecal( self.unit.CachePosition, Random()*6.28, (self.SplatTexture.AlphaNormals[1] or self.SplatTexture.AlphaNormals), '', 'Alpha Normals', radius * (self.SplatTexture.AlphaNormals[2] or 2), radius * (self.SplatTexture.AlphaNormals[2] or 2), radius * 30, bp.Damage * 15, army )
                    end
                end

                --local proj = self.unit:CreateProjectile(bp.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)
                
                --if proj.EffectThread then
                    --proj:ForkThread(proj.EffectThread)
                --end
 
                self.unit.DeathWeaponEnabled = false

                self.unit:CosmeticDamage(radius)
                
                DamageArea(self.unit, self.unit.CachePosition, radius, bp.Damage, bp.DamageType or 'Normal', bp.DamageFriendly or false)

                self.unit:PlayUnitSound('Destroyed')
                
                self.unit:Destroy()
                
                ChangeState( self, self.DeadState)

            end,
        },
    },

    CosmeticDamage = function(self, radius)

        local halfr = radius * 0.5

        DamageArea(self, self.CachePosition, halfr, 1, 'Force', true)
        DamageArea(self, self.CachePosition, halfr, 1, 'Force', true)
        DamageRing(self, self.CachePosition, 0.1, radius, 10, 'Fire', false, false)
    end,

    OnCreate = function(self,builder,layer)

        StructureUnit.OnCreate(self)

        --enable cloaking and stealth
        self:EnableIntel('Cloak')
        self:EnableIntel('CloakField')
        self:EnableIntel('RadarStealth')
        self:EnableIntel('SonarStealth')

        if not self.CachePosition then
            self.CachePosition = {moho.entity_methods.GetPositionXYZ(self)}
        end

        if self:GetBlueprint().FootprintDummyId then
            
            self.blocker = CreateUnitHPR(self:GetBlueprint().FootprintDummyId,self:GetArmy(),self.CachePosition[1],self.CachePosition[2],self.CachePosition[3],0,0,0)
            self.Trash:Add(self.blocker)
        end
    end,

    OnStopBeingBuilt = function(self,builder,layer)

        StructureUnit.OnStopBeingBuilt(self,builder,layer)

        if self:GetCurrentLayer() == 'Sub' then

            local bp = __blueprints[self.BpId]

            self.Trash:Add(CreateSlider(self, 0, 0, -1, 0, 5, true))

            self:SetCollisionShape('Box',
                bp.CollisionOffsetX or 0,
                (bp.CollisionOffsetY or 0) - 1 + bp.SizeY * 0.5,
                bp.CollisionOffsetZ or 0,
                bp.SizeX * 0.5,
                bp.SizeY * 0.5,
                bp.SizeZ * 0.5
            )
        end

        if self.blocker then
            --This tricks the engine into thinking the area is clear:
            --Removing a building with an overlapping footprint from the same layer.
            self.blocker:Destroy()
        end
        
        self:SetMaintenanceConsumptionActive()

        --Force update of the cloak effect if there is a cloak mesh.
        if __blueprints[self.BpId].Display.CloakMeshBlueprint then
            self:ForkThread(
                function()
                    coroutine.yield(1)
                    self:UpdateCloakEffect(true, 'Cloak')
                end
            )
        end
    end,

    OnScriptBitSet = function(self, bit)

        UnitOnScriptBitSet(self, bit)

        if bit == 1 then
            self:GetWeaponByLabel('Suicide'):OnWeaponFired()
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        
        StructureUnitOnKilled(self, instigator, type, 2)
        
        self:Destroy()
    end,
}

---------------------
-- Nuke Mine script
---------------------
NukeMineStructureUnit = Class(MineStructureUnit) {

    Weapons = {

        Suicide = Class(import('/lua/sim/DefaultWeapons.lua').BareBonesWeapon) {

            OnWeaponFired = function(self)
            
                local bp = self.bp -- Weapon blueprint

                local proj = self.unit:CreateProjectile(bp.ProjectileId, 0, 0, 0, nil, nil, nil):SetCollision(false)

                if ScenarioInfo.ProjectileDialog then
                    LOG("*AI DEBUG SuicideWeapon (Nuke) OnWeaponFired "..repr(bp.Label).." at "..GetGameTick() )
                end

                self.unit.DeathWeaponEnabled = false
                
                proj:ForkThread(proj.EffectThread)

                if __blueprints[bp.ProjectileId].Audio.NukeExplosion then
                    self:PlaySound(__blueprints[bp.ProjectileId].Audio.NukeExplosion)
                end

                DamageArea(self.unit, self.unit.CachePosition, bp.NukeInnerRingRadius, bp.NukeInnerRingDamage, 'Nuke', true, true)
                DamageArea(self.unit, self.unit.CachePosition, bp.NukeOuterRingRadius, bp.NukeOuterRingDamage, 'Nuke', true, true)

                self.unit:CosmeticDamage(bp.NukeInnerRingRadius)
                self.unit:Destroy()
            end,
        },
    },
    
    OnCreate = function(self,builder,layer)
    
        MineStructureUnit.OnCreate(self,builder,layer)
        
        self:SetFireState(1)    -- set to hold fire -- requires manual detonation

    end,

}
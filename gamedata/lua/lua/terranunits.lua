---   /lua/terranunits.lua
#**  Author(s): John Comes, Dave Tomandl, Gordon Duclos
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.

# TERRAN DEFAULT UNITS

local DefaultUnitsFile = import('defaultunits.lua')

local AirStagingPlatformUnit = DefaultUnitsFile.AirStagingPlatformUnit
local AirUnit = DefaultUnitsFile.AirUnit
local ConcreteStructureUnit = DefaultUnitsFile.ConcreteStructureUnit
local WallStructureUnit = import('defaultunits.lua').WallStructureUnit
local ConstructionUnit = DefaultUnitsFile.ConstructionUnit
local EnergyCreationUnit = DefaultUnitsFile.EnergyCreationUnit

local FactoryUnit = DefaultUnitsFile.FactoryUnit

local MassCollectionUnit = DefaultUnitsFile.MassCollectionUnit
local MassFabricationUnit = DefaultUnitsFile.MassFabricationUnit

local MobileUnit = DefaultUnitsFile.MobileUnit
local RadarUnit = DefaultUnitsFile.RadarUnit

local SeaUnit = DefaultUnitsFile.SeaUnit

local ShieldStructureUnit = DefaultUnitsFile.ShieldStructureUnit
local SonarUnit = DefaultUnitsFile.SonarUnit
local StructureUnit = DefaultUnitsFile.StructureUnit
local SubUnit = DefaultUnitsFile.SubUnit

local WalkingLandUnit = DefaultUnitsFile.WalkingLandUnit

local QuantumGateUnit = DefaultUnitsFile.QuantumGateUnit

local RadarJammerUnit = DefaultUnitsFile.RadarJammerUnit

local PlayEffectsAtBones = import('effectutilities.lua').CreateBoneTableRangedScaleEffects
local CreateBuildCubeThread = import('effectutilities.lua').CreateBuildCubeThread
local CreateDefaultBuildBeams = import('effectutilities.lua').CreateDefaultBuildBeams
local CreateUEFBuildSliceBeams = import('effectutilities.lua').CreateUEFBuildSliceBeams

local CreateAttachedEmitter = CreateAttachedEmitter
local CreateRotator = CreateRotator
local ChangeState = ChangeState
local EntityCategoryContains = EntityCategoryContains
local ForkThread = ForkThread
local KillThread = KillThread
local WaitTicks = coroutine.yield

TAirFactoryUnit = Class(FactoryUnit) {
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        WaitTicks(1)
        for k, v in self:GetBlueprint().General.BuildBones.BuildEffectBones do
            self.BuildEffectsBag:Add( CreateAttachedEmitter( self, v, self:GetArmy(), '/effects/emitters/flashing_blue_glow_01_emit.bp' ) )         
            self.BuildEffectsBag:Add( self:ForkThread( CreateDefaultBuildBeams, unitBeingBuilt, {v}, self.BuildEffectsBag ) )
        end
    end,
   
    OnPaused = function(self)
        FactoryUnit.OnPaused(self)
        self:StopArmsMoving()
    end,
    
    OnUnpaused = function(self)
        FactoryUnit.OnUnpaused(self)
        if self:GetNumBuildOrders(categories.ALLUNITS) > 0 and not self:IsUnitState('Upgrading') then
            self:StartArmsMoving()
        end
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )
        FactoryUnit.OnStartBuild(self, unitBeingBuilt, order )
        if order != 'Upgrade' then
            self:StartArmsMoving()
        end
    end,
   
    OnStopBuild = function(self, unitBuilding)
        FactoryUnit.OnStopBuild(self, unitBuilding)
        self:StopArmsMoving()
    end,

    OnFailedToBuild = function(self)
        FactoryUnit.OnFailedToBuild(self)
        self:StopArmsMoving()
    end,
   
    StartArmsMoving = function(self)
        self.ArmsThread = self:ForkThread(self.MovingArmsThread)
    end,

    MovingArmsThread = function(self)
    end,
    
    StopArmsMoving = function(self)
        if self.ArmsThread then
            KillThread(self.ArmsThread)
            self.ArmsThread = nil
        end
    end,
}

TLandFactoryUnit = Class(FactoryUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        WaitTicks(1)
        local army = self:GetArmy()
        for k, v in self:GetBlueprint().General.BuildBones.BuildEffectBones do
            self.BuildEffectsBag:Add( CreateAttachedEmitter( self, v, army, '/effects/emitters/flashing_blue_glow_01_emit.bp' ) ) 
            self.BuildEffectsBag:Add( self:ForkThread( CreateDefaultBuildBeams, unitBeingBuilt, {v}, self.BuildEffectsBag ) )
        end
    end,
}

TSeaFactoryUnit = Class(TAirFactoryUnit) {}

TQuantumGateUnit = Class(QuantumGateUnit) {}

TAirStagingPlatformUnit = Class(AirStagingPlatformUnit) {}

TAirUnit = Class(AirUnit) {}

TConcreteStructureUnit = Class(ConcreteStructureUnit) {}

TConstructionUnit = Class(ConstructionUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local UpgradesFrom = unitBeingBuilt:GetBlueprint().General.UpgradesFrom
        #-- If we are assisting an upgrading unit, or repairing a unit, play seperate effects
        if (order == 'Repair' and not unitBeingBuilt:IsBeingBuilt()) or (UpgradesFrom and UpgradesFrom != 'none' and self:IsUnitState('Guarding'))then
            CreateDefaultBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
        else
            CreateUEFBuildSliceBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )        
        end           
    end,

    OnLayerChange = function(self, new, old)
        ConstructionUnit.OnLayerChange(self, new, old)
        if self:GetBlueprint().Display.AnimationWater then
            if self.TerrainLayerTransitionThread then
                self.TerrainLayerTransitionThread:Destroy()
                self.TerrainLayerTransitionThread = nil
            end
            if (new == 'Land') and (old != 'None') then
                self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, false)
            elseif (new == 'Water') then
                self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, true)
            end
        end
    end,

    TransformThread = function(self, water)
        
        if not self.TransformManipulator then
            self.TransformManipulator = CreateAnimator(self)
            self.Trash:Add( self.TransformManipulator )
        end

        if water then
            self.TransformManipulator:PlayAnim(self:GetBlueprint().Display.AnimationWater)
            self.TransformManipulator:SetRate(1)
            self.TransformManipulator:SetPrecedence(0)
        else
            self.TransformManipulator:SetRate(-1)
            self.TransformManipulator:SetPrecedence(0)
            WaitFor(self.TransformManipulator)
            self.TransformManipulator:Destroy()
            self.TransformManipulator = nil
        end
    end,
}

TEnergyCreationUnit = Class(EnergyCreationUnit) {}

TEnergyStorageUnit = Class(StructureUnit) {}

THoverLandUnit = Class(MobileUnit) {}

TLandUnit = Class(MobileUnit) {}

TMassCollectionUnit = Class(MassCollectionUnit) {

    StartBeingBuiltEffects = function(self, builder, layer)
		self:SetMesh(self:GetBlueprint().Display.BuildMeshBlueprint, true)
        if self:GetBlueprint().General.UpgradesFrom != builder:GetUnitId() then
			self:HideBone(0, true)        
            self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag ))
        end
    end,    
}

TMassFabricationUnit = Class(MassFabricationUnit) {}

TMassStorageUnit = Class(StructureUnit) {}

TMobileFactoryUnit = Class(MobileUnit) {

    StartBeingBuiltEffects = function(self, builder, layer)
		self:SetMesh(self:GetBlueprint().Display.BuildMeshBlueprint, true)
        if self:GetBlueprint().General.UpgradesFrom != builder:GetUnitId() then
			self:HideBone(0, true)        
            self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag ))
        end
    end,   
}

TRadarUnit = Class(RadarUnit) {}

TSonarUnit = Class(SonarUnit) {}

TSeaUnit = Class(SeaUnit) {}

TShieldLandUnit = Class(MobileUnit) {}

TShieldStructureUnit = Class(ShieldStructureUnit) {
    StartBeingBuiltEffects = function(self,builder,layer)
    	self:SetMesh(self:GetBlueprint().Display.BuildMeshBlueprint, true)
        if builder and EntityCategoryContains(categories.MOBILE, builder) then
            self:HideBone(0, true)
            self.OnBeingBuiltEffectsBag:Add( self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag )	)	
        end
    end,
}

TStructureUnit = Class(StructureUnit) {}

TRadarJammerUnit = Class(RadarJammerUnit) {
    OnIntelEnabled = function(self)
        if not self.MySpinner then
            self.MySpinner = CreateRotator(self, 'Spinner', 'y', nil, 0, 45, 180)
            self.Trash:Add(self.MySpinner)
        end
        RadarJammerUnit.OnIntelEnabled(self)
        self.MySpinner:SetTargetSpeed(180)
    end,
    
    OnIntelDisabled = function(self)
        RadarJammerUnit.OnIntelDisabled(self)
        self.MySpinner:SetTargetSpeed(0)
    end,
}

TSubUnit = Class(SubUnit) {}

TTransportBeaconUnit = Class(DefaultUnitsFile.TransportBeaconUnit) {}

TWalkingLandUnit = Class(WalkingLandUnit) {

    WalkingAnimRate = 1,
    IdleAnimRate = 1,
    DisabledBones = {},
}

TWallStructureUnit = Class(WallStructureUnit) {}

TCivilianStructureUnit = Class(StructureUnit) {}

TShieldSeaUnit = Class(SeaUnit) {}

TPodTowerUnit = Class(TStructureUnit) {

    OnStopBeingBuilt = function(self, builder, layer)
	
		--self.EventCallbacks.OnTransportAttach = {}
		--self.EventCallbacks.OnTransportDetach = {}
		
        TStructureUnit.OnStopBeingBuilt(self, builder, layer)
        ChangeState( self, self.FinishedBeingBuilt )
    end,
    
    PodTransfer = function(self, pod, podData)
        #-- Set the pod as active, set new parent and creator for the pod, store the pod handle
        if not self.PodData[pod.PodName].Active then
            if not self.PodData then
                self.PodData = {}
            end
            self.PodData[pod.PodName] = table.deepcopy( podData )
            self.PodData[pod.PodName].PodHandle = pod
            pod:SetParent(self, pod.PodName)
        end
    end,
    
    OnCaptured = function(self, captor)
        -- Iterate through pod data and set up callbacks for transfer of pods.
        -- We never get the handle to the new tower, so we set up a new unit capture trigger to do the same thing
        -- not the most efficient thing ever but it makes for never having to update the capture codepath here
        for k,v in self.PodData do
            if v.Active then
                v.Active = false
            
                # store off the pod name so we can give to new unit
                local podName = k
                local newPod = import('/lua/scenarioframework.lua').GiveUnitToArmy( v.PodHandle, captor:GetArmy() )
                newPod.PodName = podName
                
                #-- create a callback for when the unit is flipped.  set creator for the new pod to the new tower
                self:AddUnitCallback(
                    function(newUnit, captor)
                        newUnit:PodTransfer( newPod, v )
                    end,
                    'OnCapturedNewUnit'
                )
            end
        end
        
        -- Calling the parent OnCaptured will cause all the callbacks to happen and happiness will reign !
        TStructureUnit.OnCaptured(self, captor)
    end,
    
    OnDestroy = function(self)
        TStructureUnit.OnDestroy(self)
        #-- Iterate through pod data, kill all the pods and set them inactive
        if self.PodData then
            for k,v in self.PodData do
                if v.Active and not v.PodHandle.Dead then
                    v.PodHandle:Kill()
                end
            end
        end
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order )
        TStructureUnit.OnStartBuild(self,unitBeingBuilt,order)
        local unitid = self:GetBlueprint().General.UpgradesTo
        if unitBeingBuilt:GetUnitId() == unitid and order == 'Upgrade' then
            self.NowUpgrading = true
            ChangeState( self, self.UpgradingState )
        end
    end,
    
    NotifyOfPodDeath = function(self,podName)
        self.PodData[podName].Active = false
    end,
    
    NotifyOfPodStartBuild = function(self)
        if not self.OpeningAnimationStarted then
            self.OpeningAnimationStarted = true
            local bp = self:GetBlueprint()
            if not bp.Display.AnimationOpen then return end    
            if not self.OpenAnim then
                self.OpenAnim = CreateAnimator(self)
                self.Trash:Add(self.OpenAnim)
            end
            self.OpenAnim:PlayAnim(bp.Display.AnimationOpen, false):SetRate(2.0)
            WaitTicks(5)
            if not self.NowUpgrading then
                self.OpenAnim:SetRate(0)
            end
        end    
    end,
    
    NotifyOfPodStopBuild = function(self)
        if self.OpeningAnimationStarted then
            local bp = self:GetBlueprint()
            if not bp.Display.AnimationOpen then return end
            if not self.OpenAnim then return end
            self.OpenAnim:SetRate(1.5)
            self.OpeningAnimationStarted = false
        end    
    end,
    
    SetPodConsumptionRebuildRate = function(self, podData)
        local bp = self:GetBlueprint()
        #-- Get build rate of tower
        local buildRate = bp.Economy.BuildRate
        
        local energy_rate = ( podData.BuildCostEnergy / podData.BuildTime ) * buildRate
        local mass_rate = ( podData.BuildCostMass / podData.BuildTime ) * buildRate
        
        #-- Set Consumption - Buff system will replace this here
        self:SetConsumptionPerSecondEnergy(energy_rate)
        self:SetConsumptionPerSecondMass(mass_rate)
        self:SetConsumptionActive(true)
    end,
    
    CreatePod = function(self, podName)
        local location = self:GetPosition( self.PodData[podName].PodAttachpoint )
        self.PodData[podName].PodHandle = CreateUnitHPR(self.PodData[podName].PodUnitID, self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
        self.PodData[podName].PodHandle:SetParent(self, podName)
        self.PodData[podName].Active = true
    end,
    
    OnTransportAttach = function(self, bone, attachee)
        attachee:SetDoNotTarget(true)
        MobileUnit.OnTransportAttach(self, bone, attachee)
    end,
    
    OnTransportDetach = function(self, bone, attachee)
        attachee:SetDoNotTarget(false)
        MobileUnit.OnTransportDetach(self, bone, attachee)
    end,
    
    FinishedBeingBuilt = State {
	
        Main = function(self)
            -- Wait one tick to make sure this wasn't captured and we don't create an extra pod
            WaitTicks(1)
            
            -- Create the pod for the kennel.  DO NOT ADD TO TRASH.
            -- This pod may have to be passed to another unit after it upgrades.  We cannot let the trash clean it up
            -- when this unit is destroyed at the tail end of the upgrade.  Make sure the unit dies properly elsewhere.

            self.TowerCaptured = nil
            local bp = self:GetBlueprint()
            for k,v in bp.Economy.EngineeringPods do
                if v.CreateWithUnit and not self.PodData[v.PodName].Active then
                    if not self.PodData then
                        self.PodData = {}
                    end
                    self.PodData[v.PodName] = table.deepcopy( v )
                    self:CreatePod( v.PodName )
                end
            end

            ChangeState( self, self.MaintainPodsState )
        end,
    },

    MaintainPodsState = State {
	
        Main = function(self)
            self.MaintainState = true
            if self.Rebuilding then
                self:SetPodConsumptionRebuildRate( self.PodData[ self.Rebuilding ] )
                ChangeState( self, self.RebuildingPodState )
            end
            local bp = self:GetBlueprint()
            while true and not self.Rebuilding do
                for k,v in bp.Economy.EngineeringPods do
                    -- Check if all the pods are active
                    if not self.PodData[v.PodName].Active then
                        -- Cost of new pod
                        local podBP = self:GetAIBrain():GetUnitBlueprint( v.PodUnitID )
                        self.PodData[v.PodName].EnergyRemain = podBP.Economy.BuildCostEnergy
                        self.PodData[v.PodName].MassRemain = podBP.Economy.BuildCostMass

                        self.PodData[v.PodName].BuildCostEnergy = podBP.Economy.BuildCostEnergy
                        self.PodData[v.PodName].BuildCostMass = podBP.Economy.BuildCostMass
                        
                        self.PodData[v.PodName].BuildTime = podBP.Economy.BuildTime
                        
                        # Enable consumption for the rebuilding
                        self:SetPodConsumptionRebuildRate(self.PodData[v.PodName])
                       
                        # Change to RebuildingPodState
                        self.Rebuilding = v.PodName
                        self:SetWorkProgress(0.01)
                        ChangeState( self, self.RebuildingPodState )
                    end
                end
                WaitTicks(10)
            end
        end,

        OnProductionPaused = function(self)
            ChangeState( self, self.PausedState )
        end,
    },
    
    RebuildingPodState = State {
	
        Main = function(self)
            local rebuildFinished = false
            local podData = self.PodData[ self.Rebuilding ]
            repeat
                WaitTicks(1)
                -- While the pod being built isn't finished
                -- Update mass and energy given to new pod - update build bar
                local fraction = self:GetResourceConsumed()
                local energy = self:GetConsumptionPerSecondEnergy() * fraction * 0.1
                local mass = self:GetConsumptionPerSecondMass() * fraction * 0.1
                
                self.PodData[ self.Rebuilding ].EnergyRemain = self.PodData[ self.Rebuilding ].EnergyRemain - energy
                self.PodData[ self.Rebuilding ].MassRemain = self.PodData[ self.Rebuilding ].MassRemain - mass
                
                self:SetWorkProgress( ( self.PodData[ self.Rebuilding ].BuildCostMass - self.PodData[ self.Rebuilding ].MassRemain ) / self.PodData[ self.Rebuilding ].BuildCostMass )
                
                if ( self.PodData[ self.Rebuilding ].EnergyRemain <= 0 ) and ( self.PodData[ self.Rebuilding ].MassRemain <= 0 ) then
                    rebuildFinished = true
                end
            until rebuildFinished
            
            -- create pod, deactivate consumption, clear building
            self:CreatePod( self.Rebuilding )
            self.Rebuilding = false
            self:SetWorkProgress(0)
            self:SetConsumptionPerSecondEnergy(0)
            self:SetConsumptionPerSecondMass(0)
            self:SetConsumptionActive(false)
            
            ChangeState( self, self.MaintainPodsState )
        end,
        
        OnProductionPaused = function(self)
            self:SetConsumptionPerSecondEnergy(0)
            self:SetConsumptionPerSecondMass(0)
            self:SetConsumptionActive(false)
            ChangeState( self, self.PausedState )
        end,
    },
    
    PausedState = State {
        Main = function(self)
            self.MaintainState = false
        end,

        OnProductionUnpaused = function(self)
            ChangeState( self, self.MaintainPodsState )
        end,
    },

    UpgradingState = State {
	
        Main = function(self)

            local bp = self:GetBlueprint().Display
			
            self:DestroyTarmac()
            self:PlayUnitSound('UpgradeStart')
            self:DisableDefaultToggleCaps()
			
            if bp.AnimationUpgrade then
                local unitBuilding = self.UnitBeingBuilt
                self.AnimatorUpgradeManip = CreateAnimator(self)
                self.Trash:Add(self.AnimatorUpgradeManip)
                local fractionOfComplete = 0
                self:StartUpgradeEffects(unitBuilding)
                self.AnimatorUpgradeManip:PlayAnim(bp.AnimationUpgrade, false):SetRate(0)

                while fractionOfComplete < 1 and not self.Dead do
                    fractionOfComplete = unitBuilding:GetFractionComplete()
                    self.AnimatorUpgradeManip:SetAnimationFraction(fractionOfComplete)
                    WaitTicks(1)
                end
                if not self.Dead then
                    self.AnimatorUpgradeManip:SetRate(1)
                end
            end
        end,

        OnProductionPaused = function(self)
            self.MaintainState = false
        end,
        
        OnProductionUnpaused = function(self)
            self.MaintainState = true
        end,
        
        OnStopBuild = function(self, unitBuilding)
            TStructureUnit.OnStopBuild(self, unitBuilding)
            self:EnableDefaultToggleCaps()
            if unitBuilding:GetFractionComplete() == 1 then
                NotifyUpgrade(self, unitBuilding)
                self:StopUpgradeEffects(unitBuilding)
                self:PlayUnitSound('UpgradeEnd')
                -- Iterate through pod data and transfer pods to the new unit
                for k,v in self.PodData do
                    if v.Active then
                        unitBuilding:PodTransfer(v.PodHandle, v)
                        v.Active = false
                    end
                end
                self:Destroy()
            end
        end,

        OnFailedToBuild = function(self)
            TStructureUnit.OnFailedToBuild(self)
            self:EnableDefaultToggleCaps()
            self.AnimatorUpgradeManip:Destroy()

            --self:PlayUnitSound('UpgradeFailed')
            --self:PlayActiveAnimation()
            self:CreateTarmac(true, true, true, self.TarmacBag.Orientation, self.TarmacBag.CurrentBP)
            if self.MaintainState then
                ChangeState(self, self.MaintainPodsState)
            else
                ChangeState(self, self.PausedState)
            end
        end,
    },
}
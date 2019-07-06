---  /lua/cybranunits.lua
-- CYBRAN DEFAULT UNITS

local DefaultUnitsFile = import('defaultunits.lua')

local AirStagingPlatformUnit = DefaultUnitsFile.AirStagingPlatformUnit
local AirUnit = DefaultUnitsFile.AirUnit
local ConcreteStructureUnit = DefaultUnitsFile.ConcreteStructureUnit
local WallStructureUnit = import('defaultunits.lua').WallStructureUnit
local ConstructionUnit = DefaultUnitsFile.ConstructionUnit

local FactoryUnit = DefaultUnitsFile.FactoryUnit


local MobileUnit = DefaultUnitsFile.MobileUnit

local SeaUnit = DefaultUnitsFile.SeaUnit

local ShieldStructureUnit = DefaultUnitsFile.ShieldStructureUnit
local StructureUnit = DefaultUnitsFile.StructureUnit
local QuantumGateUnit = DefaultUnitsFile.QuantumGateUnit
local RadarJammerUnit = DefaultUnitsFile.RadarJammerUnit

local EffectTemplate = import('/lua/EffectTemplates.lua')

local CreateCybranBuildBeams = import('EffectUtilities.lua').CreateCybranBuildBeams
local CreateCybranEngineerBuildEffects = import('EffectUtilities.lua').CreateCybranEngineerBuildEffects
local CreateCybranFactoryBuildEffects = import('EffectUtilities.lua').CreateCybranFactoryBuildEffects
local SpawnBuildBots = import('EffectUtilities.lua').SpawnBuildBots

local ForkThread = ForkThread
local KillThread = KillThread
local WaitSeconds = WaitSeconds

local WaitTicks = coroutine.yield

local CreateAttachedEmitter = CreateAttachedEmitter

--  AIR FACTORY STRUCTURES
CAirFactoryUnit = Class(FactoryUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        if not unitBeingBuilt then return end
        WaitTicks( 1 )
        CreateCybranFactoryBuildEffects( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones, self.BuildEffectsBag )
    end,
    
    StartBuildFx = function(self, unitBeingBuilt)
        if not unitBeingBuilt then
			return
		end
        
        if not self.BuildAnimManip then
            self.BuildAnimManip = CreateAnimator(self)
            self.BuildAnimManip:PlayAnim( __blueprints[self.BlueprintID].Display.AnimationBuild, true):SetRate(0)
            self.Trash:Add(self.BuildAnimManip)
        end
        self.BuildAnimManip:SetRate(1)
    end,
    
    -- StopBuildFx = function(self)
        -- if self.BuildAnimManip then
            -- self.BuildAnimManip:SetRate(0)
        -- end
    -- end,
    
    OnPaused = function(self)
        StructureUnit.OnPaused(self)
        self:StopBuildFx()
    end,

    OnUnpaused = function(self)
        StructureUnit.OnUnpaused(self)
		
        if self:IsUnitState('Building') then
            self:StartBuildFx(self:GetFocusUnit())
        end
    end,
}   

-- AIR STAGING STRUCTURES
CAirStagingPlatformUnit = Class(AirStagingPlatformUnit) {}

--  AIR UNITS
CAirUnit = Class(AirUnit) {}

--  WALL  STRUCTURES
CConcreteStructureUnit = Class(ConcreteStructureUnit) {}

--  CONSTRUCTION UNITS
CConstructionUnit = Class(ConstructionUnit){

    OnStopBeingBuilt = function(self,builder,layer)
	
        ConstructionUnit.OnStopBeingBuilt(self,builder,layer)

        if(self:GetCurrentLayer() == 'Water') then
		
            self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, true)
			
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
		
		self.TerrainLayerTransitionThread = nil
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
	
        local buildbots = SpawnBuildBots( self, unitBeingBuilt, table.getn( __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones), self.BuildEffectsBag )
		
        CreateCybranEngineerBuildEffects( self, self:GetBlueprint().General.BuildBones.BuildEffectBones, buildbots, self.BuildEffectsBag )
    end,
}

--  ENERGY CREATION UNITS
CEnergyCreationUnit = Class(DefaultUnitsFile.EnergyCreationUnit) {
--[[    
    OnStopBeingBuilt = function(self,builder,layer)
	
        DefaultUnitsFile.EnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
		
        if self.AmbientEffects then
            for k, v in EffectTemplate[self.AmbientEffects] do
                CreateAttachedEmitter(self, 0, self.Sync.army, v)
            end
        end
    end,
--]]
}

-- ENERGY STORAGE STRUCTURES
CEnergyStorageUnit = Class(StructureUnit) {}

--  LAND FACTORY STRUCTURES
CLandFactoryUnit = Class(FactoryUnit) {
   
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        if not unitBeingBuilt then return end
        WaitTicks( 1 )
        CreateCybranFactoryBuildEffects( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones, self.BuildEffectsBag )
    end,   
   
    StartBuildFx = function(self, unitBeingBuilt)
        if not unitBeingBuilt then
            unitBeingBuilt = self:GetFocusUnit()
        end
        
        # Start build process
        if not self.BuildAnimManip then
            self.BuildAnimManip = CreateAnimator(self)
            self.BuildAnimManip:PlayAnim( __blueprints[self.BlueprintID].Display.AnimationBuild, true):SetRate(0)
            self.Trash:Add(self.BuildAnimManip)
        end

        self.BuildAnimManip:SetRate(1)
    end,
    
    -- StopBuildFx = function(self)
        -- if self.BuildAnimManip then
            -- self.BuildAnimManip:SetRate(0)
        -- end
    -- end,
    
    OnPaused = function(self)
        StructureUnit.OnPaused(self)
		
        self:StopBuildFx(self:GetFocusUnit())
    end,

    OnUnpaused = function(self)
        StructureUnit.OnUnpaused(self)
		
        if self:IsUnitState('Building') then
            self:StartBuildFx(self:GetFocusUnit())
        end
    end,
}

--  LAND UNITS
CLandUnit = Class(MobileUnit) {}

--  MASS COLLECTION UNITS
CMassCollectionUnit = Class(DefaultUnitsFile.MassCollectionUnit) {}

--  MASS FABRICATION UNITS
CMassFabricationUnit = Class(DefaultUnitsFile.MassFabricationUnit) {}

--   MASS STORAGE UNITS
CMassStorageUnit = Class(StructureUnit) {}

--  RADAR STRUCTURES
CRadarUnit = Class(DefaultUnitsFile.RadarUnit) {}

--  SONAR STRUCTURES
CSonarUnit = Class(DefaultUnitsFile.SonarUnit) {}

--  SEA FACTORY STRUCTURES
CSeaFactoryUnit = Class(FactoryUnit) {
    
    StartBuildingEffects = function( self, unitBeingBuilt, order )
        self.BuildEffectsBag:Add( self:ForkThread( CreateCybranBuildBeams, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag ) )
    end,

    OnPaused = function(self)
        StructureUnit.OnPaused(self)
        self:StopArmsMoving()
    end,
    
    OnUnpaused = function(self)
        StructureUnit.OnUnpaused(self)
        if self:GetNumBuildOrders(categories.ALLUNITS) > 0 and not self:IsUnitState('Upgrading') and self:IsUnitState('Building') then
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
        self:StopArmsMoving()
		FactoryUnit.OnStopBuild(self, unitBuilding)
    end,

    OnFailedToBuild = function(self)
        self:StopArmsMoving()
        FactoryUnit.OnFailedToBuild(self)		
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

--  SEA UNITS
CSeaUnit = Class(SeaUnit) {}

--  SHIELD LAND UNITS
CShieldLandUnit = Class(MobileUnit) {}

--  SHIELD STRUCTURES
CShieldStructureUnit = Class(ShieldStructureUnit) {}

--  STRUCTURES
CStructureUnit = Class(StructureUnit) {}

--  SUBMARINE UNITS
CSubUnit = Class(DefaultUnitsFile.SubUnit) {}

--  TRANSPORT BEACON UNITS
CTransportBeaconUnit = Class(DefaultUnitsFile.TransportBeaconUnit) {}

--  WALKING LAND UNITS
CWalkingLandUnit = Class(DefaultUnitsFile.WalkingLandUnit) {}

--  WALL  STRUCTURES
CWallStructureUnit = Class(WallStructureUnit) {}

--  CIVILIAN STRUCTURES
CCivilianStructureUnit = Class(StructureUnit) {}

--  QUANTUM GATE UNITS
CQuantumGateUnit = Class(QuantumGateUnit) {}

--  RADAR JAMMER UNITS
CRadarJammerUnit = Class(RadarJammerUnit) {}

CConstructionEggUnit = Class(StructureUnit) {

    OnStopBeingBuilt = function(self, builder, layer)

        FactoryUnit.OnStopBeingBuilt(self,builder,layer)
		
        local bp = __blueprints[self.BlueprintID]
        local buildUnit = bp.Economy.BuildUnit
        
        local pos = self:GetPosition()
        
        local aiBrain = self:GetAIBrain()
		
        CreateUnitHPR(buildUnit, aiBrain.Name, pos[1], pos[2], pos[3], 0, 0, 0 )
		
        ForkThread( function()
                        self.OpenAnimManip = CreateAnimator(self)
                        self.Trash:Add(self.OpenAnimManip)
                        self.OpenAnimManip:PlayAnim( bp.Display.AnimationOpen, false):SetRate(0.25)

                        WaitFor(self.OpenAnimManip)
                        
                        self.EggSlider = CreateSlider(self, 0, 0, -20, 0, 10)
                        self.Trash:Add(self.EggSlider)
                        
                        WaitFor(self.EggSlider)
                        
                        self:Destroy()
                    end
                  )
        
        #ChangeState( self, self.EggConstruction )
    end,
    
    EggConstruction = State {
        Main = function(self)
            local bp = __blueprints[self.BlueprintID]
            local buildUnit = bp.Economy.BuildUnit
            self:GetAIBrain():BuildUnit( self, buildUnit, 1 )
        end,
    },
    
    OnStopBuild = function(self, unitBeingBuilt, order)
		--LOG("*AI DEBUG Egg OnStopBuild")
        --if unitBeingBuilt:GetFractionComplete() == 1 then
            ForkThread(function()
                WaitTicks(1)
                self:Destroy()
            end)
        --end
    end,
	
	OnFailedToBuild = function(self)
		--LOG("*AI DEBUG Egg OnFailedToBuild")
	end,
}


#TODO: This should be made more general and put in defaultunits.lua in case other factions get similar buildings
#############################
#  CConstructionStructureUnit
#############################
CConstructionStructureUnit = Class(StructureUnit) {   
    OnCreate = function(self)
        -- Structure stuff
        StructureUnit.OnCreate(self)

        --Construction stuff   
        --self.EffectsBag = {}
		
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end

        if self:GetBlueprint().Display.AnimationBuild then
            self.BuildingOpenAnim = self:GetBlueprint().Display.AnimationBuild
        end

        if self.BuildingOpenAnim then
            self.BuildingOpenAnimManip = CreateAnimator(self)
            self.BuildingOpenAnimManip:SetPrecedence(1)
            self.BuildingOpenAnimManip:PlayAnim(self.BuildingOpenAnim, false):SetRate(0)
            if self.BuildArmManipulator then
                self.BuildArmManipulator:Disable()
            end
        end
        self.BuildingUnit = false
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order )
       
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true

        StructureUnit.OnStartBuild(self,unitBeingBuilt, order)
    end,
    
    OnStopBeingBuilt = function(self,builder,layer)
        StructureUnit.OnStopBeingBuilt(self,builder,layer)
        -- If created with F2 on land, then play the transform anim.
        if(self:GetCurrentLayer() == 'Water') then
            self.TerrainLayerTransitionThread = self:ForkThread(self.TransformThread, true)
        end
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        local buildbots = SpawnBuildBots( self, unitBeingBuilt, table.getn(self:GetBlueprint().General.BuildBones.BuildEffectBones), self.BuildEffectsBag )
        CreateCybranEngineerBuildEffects( self, self:GetBlueprint().General.BuildBones.BuildEffectBones, buildbots, self.BuildEffectsBag )
    end,
    
    -- This will only be called if not in StructureUnit's upgrade state
    OnStopBuild = function(self, unitBeingBuilt)
        StructureUnit.OnStopBuild(self, unitBeingBuilt)

        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil

        if self.BuildingOpenAnimManip and self.BuildArmManipulator then
            self.StoppedBuilding = true
        elseif self.BuildingOpenAnimManip then
            self.BuildingOpenAnimManip:SetRate(-1)
        end

        self.BuildingUnit = false
    end,
    
    OnPaused = function(self)

        StructureUnit.OnPaused(self)
		
        if self.BuildingUnit then
            StructureUnit.StopBuildingEffects(self, self.UnitBeingBuilt)
        end    
    end,
    
    OnUnpaused = function(self)
	
        if self.BuildingUnit then
            StructureUnit.StartBuildingEffects(self, self.UnitBeingBuilt, self.UnitBuildOrder)
        end
		
        StructureUnit.OnUnpaused(self)
    end,

    WaitForBuildAnimation = function(self, enable)
        if self.BuildArmManipulator then
            WaitFor(self.BuildingOpenAnimManip)
            if (enable) then
                self.BuildArmManipulator:Enable()
            end
        end
    end,

}

    -- StartBuildingEffects = function(self, unitBeingBuilt, order)
        -- StructureUnit.StartBuildingEffects(self, unitBeingBuilt, order)
    -- end,
    
    -- StopBuildingEffects = function(self, unitBeingBuilt)
        -- StructureUnit.StopBuildingEffects(self, unitBeingBuilt)
    -- end,
    
    -- OnPrepareArmToBuild = function(self)
        -- StructureUnit.OnPrepareArmToBuild(self)

        -- if self.BuildingOpenAnimManip then
            -- self.BuildingOpenAnimManip:SetRate(self:GetBlueprint().Display.AnimationBuildRate or 1)
            -- if self.BuildArmManipulator then
                -- self.StoppedBuilding = false
                -- ForkThread( self.WaitForBuildAnimation, self, true )
            -- end
        -- end
    -- end,

    -- OnStopBuilderTracking = function(self)
        -- StructureUnit.OnStopBuilderTracking(self)

        -- if self.StoppedBuilding then
            -- self.StoppedBuilding = false
            -- self.BuildArmManipulator:Disable()
            -- self.BuildingOpenAnimManip:SetRate(-(self:GetBlueprint().Display.AnimationBuildRate or 1))
        -- end
    -- end,
    
    -- CheckBuildRestriction = function(self, target_bp)
        -- if self:CanBuild(target_bp.BlueprintId) then
            -- return true
        -- else
            -- return false
        -- end
    -- end,
       

    
    -- CreateReclaimEndEffects = function( self, target )
        -- EffectUtil.PlayReclaimEndEffects( self, target )
    -- end,         
    
    -- CreateCaptureEffects = function( self, target )
		-- EffectUtil.PlayCaptureEffects( self, target, self:GetBlueprint().General.BuildBones.BuildEffectBones or {0,}, self.CaptureEffectsBag )
    -- end,    
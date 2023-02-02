---   /lua/terranunits.lua
--**  Author(s): John Comes, Dave Tomandl, Gordon Duclos
--**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.

-- TERRAN DEFAULT UNITS

local DefaultUnitsFile = import('defaultunits.lua')

local ConstructionUnit = DefaultUnitsFile.ConstructionUnit

local FactoryUnit = DefaultUnitsFile.FactoryUnit

local MassCollectionUnit = DefaultUnitsFile.MassCollectionUnit

local MobileUnit = DefaultUnitsFile.MobileUnit

local RadarJammerUnit = DefaultUnitsFile.RadarJammerUnit

local ShieldStructureUnit = DefaultUnitsFile.StructureUnit

local StructureUnit = DefaultUnitsFile.StructureUnit

local CreateBuildCubeThread = import('effectutilities.lua').CreateBuildCubeThread
local CreateDefaultBuildBeams = import('effectutilities.lua').CreateDefaultBuildBeams
local CreateUEFBuildSliceBeams = import('effectutilities.lua').CreateUEFBuildSliceBeams

local CreateRotator = CreateRotator

local ChangeState = ChangeState

local EntityCategoryContains = EntityCategoryContains
local ForkThread = ForkThread
local KillThread = KillThread
local WaitTicks = coroutine.yield

local LOUDWARP = Warp

local HideBone = moho.unit_methods.HideBone
local ScaleEmitter = moho.IEffect.ScaleEmitter
local SetMesh = moho.entity_methods.SetMesh

local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

TAirFactoryUnit = Class(FactoryUnit) {
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )

        TrashAdd( self.BuildEffectsBag, self:ForkThread( CreateDefaultBuildBeams, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag ) )
		
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

        if self.BuildProjectile then
        
            for _, v in self.BuildProjectile do
           
                ScaleEmitter( v.Emitter, .1)
                ScaleEmitter( v.Sparker, .1)

                LOUDWARP( v, self.CachePosition )
            end
        end

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
    
        if order != 'Upgrade' then

            -- the projectile used to attach the beam to, is permanently created - for each bone
            -- this process creates the sparks on the bone and the projectile, and creates the beam between them
            -- then launches a thread to move the particle about while the unit is being built
            TrashAdd( self.BuildEffectsBag, self:ForkThread( CreateDefaultBuildBeams, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag ) )
        end
        
    end,

    OnStopBuild = function(self, unitBeingBuilt)

        if self.BuildProjectile then
        
            for _, v in self.BuildProjectile do
           
                ScaleEmitter( v.Emitter, .1)
                ScaleEmitter( v.Sparker, .1)
                
                -- return projectile to source
                LOUDWARP( v, self.CachePosition )
            end
        end
        
        FactoryUnit.OnStopBuild( self, unitBeingBuilt )
    end,

}

TSeaFactoryUnit = Class(TAirFactoryUnit) {}

TConstructionUnit = Class(ConstructionUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        TrashAdd( self.BuildEffectsBag, self:ForkThread( CreateUEFBuildSliceBeams, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag ) )
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
        ConstructionUnit.OnStopBuild(self, unitBeingBuilt)
    end,

    OnLayerChange = function(self, new, old)
	
        ConstructionUnit.OnLayerChange(self, new, old)
		
        if __blueprints[self.BlueprintID].Display.AnimationWater then
		
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
            TrashAdd( self.Trash, self.TransformManipulator )
        end

        if water then
            self.TransformManipulator:PlayAnim(__blueprints[self.BlueprintID].Display.AnimationWater)
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

TConstructionStructureUnit = Class(StructureUnit) {
   
    OnCreate = function(self)
        -- Structure stuff
        StructureUnit.OnCreate(self)

        local bp = __blueprints[self.BlueprintID]
        
        --Construction stuff   
        --self.EffectsBag = {}
		
        if bp.General.BuildBones then
            self:SetupBuildBones()
        end

        if bp.Display.AnimationBuild then
            self.BuildingOpenAnim = bp.Display.AnimationBuild
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
        
        TrashAdd( self.BuildEffectsBag, self:ForkThread( CreateUEFBuildSliceBeams, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.BuildEffectsBag ) )    

    end,
    
    -- This will only be called if not in StructureUnit's upgrade state
    OnStopBuild = function(self, unitBeingBuilt)
    
        if self.BuildBots then

            for _, bot in self.BuildBots do

                if bot.BuildProjectile then
                
                    for _,v in bot.BuildProjectile do

                        TrashDestroy( v.BuildEffectsBag )
                        
                        if v.Detached then
                            v:AttachTo( bot, v.Name )
                        end
                        
                        v.Detached = false                        
        
                        v.Emitter:ScaleEmitter(0.01)
                        v.Sparker:ScaleEmitter(0.01)
                    end
                end    
        
                TrashDestroy( bot.BuildEffectsBag )
                
                IssueClearCommands( {bot} )
                
                bot:AttachTo( self, 0 )
                bot.Detached = false

            end
            
            for _, emitter in self.BuildEmitter do
                emitter:ScaleEmitter( 0.01 )
            end

        end

        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil

        TrashDestroy( self.BuildEffectsBag )
   
        if self.BuildingOpenAnimManip and self.BuildArmManipulator then
        
            self.StoppedBuilding = true
            
        elseif self.BuildingOpenAnimManip then
        
            self.BuildingOpenAnimManip:SetRate(-1)
            
        end

        self.BuildingUnit = false
    
        StructureUnit.OnStopBuild(self, unitBeingBuilt)
       
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

TMassCollectionUnit = Class(MassCollectionUnit) {

    StartBeingBuiltEffects = function(self, builder, layer)
	
		SetMesh( self, __blueprints[self.BlueprintID].Display.BuildMeshBlueprint, true)
		
        if __blueprints[self.BlueprintID].General.UpgradesFrom != builder.BlueprintID then
        
			HideBone( self, 0, true)        
            TrashAdd( self.OnBeingBuiltEffectsBag, self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag ))
            
        end
		
    end,    
}

TMobileFactoryUnit = Class(MobileUnit) {

    StartBeingBuiltEffects = function(self, builder, layer)
	
		SetMesh( self, __blueprints[self.BlueprintID].Display.BuildMeshBlueprint, true)
		
        if __blueprints[self.BlueprintID].General.UpgradesFrom != builder.BlueprintID then
        
			HideBone( self, 0, true)        
            TrashAdd( self.OnBeingBuiltEffectsBag, self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag ))
            
        end
    end,   
}

TShieldStructureUnit = Class(ShieldStructureUnit) {

    StartBeingBuiltEffects = function(self,builder,layer)
	
    	SetMesh( self, __blueprints[self.BlueprintID].Display.BuildMeshBlueprint, true)
		
        if builder and EntityCategoryContains(categories.MOBILE, builder) then
		
            HideBone( self, 0, true)
            TrashAdd( self.OnBeingBuiltEffectsBag, self:ForkThread( CreateBuildCubeThread, builder, self.OnBeingBuiltEffectsBag )	)	
			
        end
		
    end,
}

TRadarJammerUnit = Class(RadarJammerUnit) {

    OnIntelEnabled = function(self,intel)
        if not self.MySpinner then
            self.MySpinner = CreateRotator(self, 'Spinner', 'y', nil, 0, 45, 180)
            TrashAdd( self.Trash, self.MySpinner )
        end
        RadarJammerUnit.OnIntelEnabled(self,intel)
        self.MySpinner:SetTargetSpeed(180)
    end,
    
    OnIntelDisabled = function(self,intel)
        RadarJammerUnit.OnIntelDisabled(self,intel)
        self.MySpinner:SetTargetSpeed(0)
    end,
}

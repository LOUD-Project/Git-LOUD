---  /lua/aeonunits.lua

--------------------------
-- these are deprecated --
--------------------------
--[[
local AirFactoryUnit = import('defaultunits.lua').FactoryUnit
local AirStagingPlatformUnit = import('defaultunits.lua').AirStagingPlatformUnit
local AirUnit = import('defaultunits.lua').AirUnit
local ConcreteStructureUnit = import('defaultunits.lua').ConcreteStructureUnit
local WallStructureUnit = import('defaultunits.lua').WallStructureUnit

local EnergyCreationUnit = import('defaultunits.lua').EnergyCreationUnit

local LandFactoryUnit = import('defaultunits.lua').FactoryUnit
local MassCollectionUnit = import('defaultunits.lua').MassCollectionUnit
local MassFabricationUnit = import('defaultunits.lua').MassFabricationUnit

local RadarUnit = import('defaultunits.lua').RadarUnit
local SeaUnit = import('/lua/defaultunits.lua').SeaUnit
local SeaFactoryUnit = import('defaultunits.lua').FactoryUnit

local SubUnit = import('defaultunits.lua').SubUnit
local SonarUnit = import('defaultunits.lua').SonarUnit
local StructureUnit = import('defaultunits.lua').StructureUnit
local QuantumGateUnit = import('defaultunits.lua').QuantumGateUnit

local TransportBeaconUnit = import('defaultunits.lua').TransportBeaconUnit
local WalkingLandUnit = import('defaultunits.lua').WalkingLandUnit
--]]
--------------------

local ConstructionUnit = import('defaultunits.lua').ConstructionUnit
local FactoryUnit = import('defaultunits.lua').FactoryUnit
local MobileUnit = import('defaultunits.lua').MobileUnit
local ShieldStructureUnit = import('defaultunits.lua').StructureUnit
local RadarJammerUnit = import('defaultunits.lua').RadarJammerUnit

local CreateAeonConstructionUnitBuildingEffects = import('/lua/EffectUtilities.lua').CreateAeonConstructionUnitBuildingEffects
local CreateAeonFactoryBuildingEffects = import('/lua/EffectUtilities.lua').CreateAeonFactoryBuildingEffects

local ScaleEmitter = moho.IEffect.ScaleEmitter

local TrashAdd = TrashBag.Add


AeonFactoryUnit = Class(FactoryUnit) {

    StartBuildFx = function( self, unitBeingBuilt )
        CreateAeonFactoryBuildingEffects( self, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.Buildbone, self.BuildEffectsBag )         
    end,
    
    OnStopBuild = function(self, unitBeingBuilt)
    
        if self.BuildEmitters then
            -- shrink the permanent emitters on each BuildEffectBone
            for _,vB in __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones do
                ScaleEmitter( self.BuildEmitters[vB], 0.05 )
            end
        end
    
        FactoryUnit.OnStopBuild(self, unitBeingBuilt)
    end,
    
}

AConstructionUnit = Class(ConstructionUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        CreateAeonConstructionUnitBuildingEffects( self, unitBeingBuilt, self.BuildEffectsBag )
    end,

    -- handle the permanent projectile & emitters
    OnStopBuild = function(self, unitBeingBuilt)
        
        for _, emit in self.BuildEmitters do
            emit:ScaleEmitter( 0.01 )
        end
    
        if self.BuildProjectile then
            if self.BuildProjectile.Detached then
                self.BuildProjectile:AttachTo( self, 0 )
            end
            self.BuildProjectile.Detached = false
        end
        
        ConstructionUnit.OnStopBuild( self, unitBeingBuilt )
    end,
}

AShieldStructureUnit = Class(ShieldStructureUnit) {
    
    RotateSpeed = 30,
    
    OnShieldEnabled = function(self)
	
        ShieldStructureUnit.OnShieldEnabled(self)
		
        local bpAnim = __blueprints[self.BlueprintID].Display.AnimationOpen
		
        if not bpAnim then return end
		
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim(bpAnim)
            TrashAdd( self.Trash, self.OpenAnim )
        end
		
        if not self.Rotator then
            self.Rotator = CreateRotator(self, 'Pod', 'z', nil, 0, 50, 0)
            TrashAdd( self.Trash, self.Rotator )
        end
		
        self.Rotator:SetSpinDown(false)
        self.Rotator:SetTargetSpeed(self.RotateSpeed)
        self.OpenAnim:SetRate(1)
    end,

    OnShieldDisabled = function(self)
	
        ShieldStructureUnit.OnShieldDisabled(self)
		
        if self.OpenAnim then
            self.OpenAnim:SetRate(-1)
        end
        if self.Rotator then
            self.Rotator:SetTargetSpeed(0)
        end
    end,    
}

ARadarJammerUnit = Class(RadarJammerUnit) {
    
    RotateSpeed = 30,
    
    OnStopBeingBuilt = function(self, builder, layer)
	
        RadarJammerUnit.OnStopBeingBuilt(self, builder, layer)
		
        local bpAnim = __blueprints[self.BlueprintID].Display.AnimationOpen
		
        if not bpAnim then return end
		
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim(bpAnim)
            TrashAdd( self.Trash, self.OpenAnim )
        end
        
        if not self.Rotator then
            self.Rotator = CreateRotator(self, 'B02', 'z', nil, 0, 50, 0)
            TrashAdd( self.Trash, self.Rotator )
        end
    end,
    
    OnIntelEnabled = function(self)
	
        RadarJammerUnit.OnIntelEnabled(self)
		
        if self.OpenAnim then
            self.OpenAnim:SetRate(1)
        end
        
        if not self.Rotator then
            self.Rotator = CreateRotator(self, 'B02', 'z', nil, 0, 50, 0)
            TrashAdd( self.Trash, self.Rotator )
        end
		
        self.Rotator:SetSpinDown(false)
        self.Rotator:SetTargetSpeed(self.RotateSpeed)
    end,

    OnIntelDisabled = function(self)
	
        RadarJammerUnit.OnIntelDisabled(self)
		
        if self.OpenAnim then
            self.OpenAnim:SetRate(-1)
        end
        
        if self.Rotator then            
            self.Rotator:SetTargetSpeed(0)
        end
    end,    
}    

AHoverLandUnit = Class(MobileUnit) {}

------------------
-- deprecated ----
------------------
--[[
AAirFactoryUnit = Class(AeonFactoryUnit) {  Buildbone = 'Attachpoint' }

ALandFactoryUnit = Class(AeonFactoryUnit) { Buildbone = 'Attachpoint' }

ASeaFactoryUnit = Class(AeonFactoryUnit) { Buildbone = 'Attachpoint01' }

AAirStagingPlatformUnit = Class(AirStagingPlatformUnit) {}

AAirUnit = Class(AirUnit) {}

AConcreteStructureUnit = Class(ConcreteStructureUnit) {}

AEnergyCreationUnit = Class(EnergyCreationUnit) {}

AEnergyStorageUnit = Class(StructureUnit) {}

ALandUnit = Class(MobileUnit) {}

AMassCollectionUnit = Class(MassCollectionUnit) {}

AMassFabricationUnit = Class(MassFabricationUnit) {}

AMassStorageUnit = Class(StructureUnit) {}

ARadarUnit = Class(RadarUnit) {}

ASonarUnit = Class(SonarUnit) {}

ASeaUnit = Class(SeaUnit) {}

AShieldHoverLandUnit = Class(MobileUnit) {}

AShieldLandUnit = Class(MobileUnit) {}

AStructureUnit = Class(StructureUnit) {}

ASubUnit = Class(SubUnit) {}

ATransportBeaconUnit = Class(TransportBeaconUnit) {}

AWalkingLandUnit = Class(WalkingLandUnit) {}

AWallStructureUnit = Class(WallStructureUnit) {}

ACivilianStructureUnit = Class(StructureUnit) {}

AQuantumGateUnit = Class(QuantumGateUnit) {}

--]]

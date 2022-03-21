---  /lua/aeonunits.lua

local AirFactoryUnit = import('defaultunits.lua').FactoryUnit
local AirStagingPlatformUnit = import('defaultunits.lua').AirStagingPlatformUnit
local AirUnit = import('defaultunits.lua').AirUnit
local ConcreteStructureUnit = import('defaultunits.lua').ConcreteStructureUnit
local WallStructureUnit = import('defaultunits.lua').WallStructureUnit
local ConstructionUnit = import('defaultunits.lua').ConstructionUnit
local EnergyCreationUnit = import('defaultunits.lua').EnergyCreationUnit

local FactoryUnit = import('defaultunits.lua').FactoryUnit
local LandFactoryUnit = import('defaultunits.lua').FactoryUnit
local MassCollectionUnit = import('defaultunits.lua').MassCollectionUnit
local MassFabricationUnit = import('defaultunits.lua').MassFabricationUnit

local MobileUnit = import('defaultunits.lua').MobileUnit
local RadarUnit = import('defaultunits.lua').RadarUnit
local SeaUnit = import('/lua/defaultunits.lua').SeaUnit
local SeaFactoryUnit = import('defaultunits.lua').FactoryUnit

local ShieldStructureUnit = import('defaultunits.lua').ShieldStructureUnit
local SubUnit = import('defaultunits.lua').SubUnit
local SonarUnit = import('defaultunits.lua').SonarUnit
local StructureUnit = import('defaultunits.lua').StructureUnit
local QuantumGateUnit = import('defaultunits.lua').QuantumGateUnit
local RadarJammerUnit = import('defaultunits.lua').RadarJammerUnit
local TransportBeaconUnit = import('defaultunits.lua').TransportBeaconUnit
local WalkingLandUnit = import('defaultunits.lua').WalkingLandUnit

local CreateAeonConstructionUnitBuildingEffects = import('/lua/EffectUtilities.lua').CreateAeonConstructionUnitBuildingEffects
local CreateAeonFactoryBuildingEffects = import('/lua/EffectUtilities.lua').CreateAeonFactoryBuildingEffects

local ForkThread = ForkThread

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add


AeonFactoryUnit = Class(FactoryUnit) {

    StartBuildFx = function( self, unitBeingBuilt )
        TrashAdd( unitBeingBuilt.Trash, self:ForkThread( CreateAeonFactoryBuildingEffects, unitBeingBuilt, __blueprints[self.BlueprintID].General.BuildBones.BuildEffectBones, self.Buildbone, self.BuildEffectsBag ) )        
    end,
}

AAirFactoryUnit = Class(AeonFactoryUnit) {  Buildbone = 'Attachpoint' }

ALandFactoryUnit = Class(AeonFactoryUnit) { Buildbone = 'Attachpoint' }

ASeaFactoryUnit = Class(AeonFactoryUnit) { Buildbone = 'Attachpoint01' }

AAirUnit = Class(AirUnit) {}

AAirStagingPlatformUnit = Class(AirStagingPlatformUnit) {}

AConcreteStructureUnit = Class(ConcreteStructureUnit) {}

AConstructionUnit = Class(ConstructionUnit) {

    CreateBuildEffects = function( self, unitBeingBuilt, order )
        CreateAeonConstructionUnitBuildingEffects( self, unitBeingBuilt, self.BuildEffectsBag )
    end,  
}

AEnergyCreationUnit = Class(EnergyCreationUnit) {}

AEnergyStorageUnit = Class(StructureUnit) {}

AHoverLandUnit = Class(MobileUnit) {}

ALandUnit = Class(MobileUnit) {}

AMassCollectionUnit = Class(MassCollectionUnit) {}

AMassFabricationUnit = Class(MassFabricationUnit) {}

AMassStorageUnit = Class(StructureUnit) {}

ARadarUnit = Class(RadarUnit) {}

ASonarUnit = Class(SonarUnit) {}

ASeaUnit = Class(SeaUnit) {}

AShieldHoverLandUnit = Class(MobileUnit) {}

AShieldLandUnit = Class(MobileUnit) {}

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

AStructureUnit = Class(StructureUnit) {}

ASubUnit = Class(SubUnit) {}

ATransportBeaconUnit = Class(TransportBeaconUnit) {}

AWalkingLandUnit = Class(WalkingLandUnit) {}

AWallStructureUnit = Class(WallStructureUnit) {}

ACivilianStructureUnit = Class(StructureUnit) {}

AQuantumGateUnit = Class(QuantumGateUnit) {}

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
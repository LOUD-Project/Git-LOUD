---  /lua/aeonunits.lua

local DefaultUnits = import('defaultunits.lua')

local ConstructionUnit      = DefaultUnits.ConstructionUnit
local FactoryUnit           = DefaultUnits.FactoryUnit
local MobileUnit            = DefaultUnits.MobileUnit
local ShieldStructureUnit   = DefaultUnits.StructureUnit
local RadarJammerUnit       = DefaultUnits.RadarJammerUnit

DefaultUnits = nil

local ConstructionUnitOnStopBuild       = ConstructionUnit.OnStopBuild
local FactoryUnitOnStopBuild            = FactoryUnit.OnStopBuild

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
    
        FactoryUnitOnStopBuild(self, unitBeingBuilt)
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
        
        ConstructionUnitOnStopBuild( self, unitBeingBuilt )
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
    
    OnIntelEnabled = function(self,intel)
	
        RadarJammerUnit.OnIntelEnabled(self,intel)
		
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

    OnIntelDisabled = function(self,intel)
	
        RadarJammerUnit.OnIntelDisabled(self,intel)
		
        if self.OpenAnim then
            self.OpenAnim:SetRate(-1)
        end
        
        if self.Rotator then            
            self.Rotator:SetTargetSpeed(0)
        end
    end,    
}    

AHoverLandUnit = Class(MobileUnit) {}

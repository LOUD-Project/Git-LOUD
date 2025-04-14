local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local FxAmbient = import('/lua/effecttemplates.lua').AResourceGenAmbient

local RemoteViewing = import('/lua/RemoteViewing.lua').RemoteViewing

AStructureUnit = RemoteViewing( AStructureUnit )

XAB3301 = Class( AStructureUnit ) {

    OnStopBeingBuilt = function(self, builder, layer)
    
        self.EmitterEffects = {}
        
        self.Rotator = CreateRotator(self, 'XAB3301', 'y', nil, 0, 4, 0)
        
        self.Trash:Add(self.Rotator)
        
        AStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
    end,

    RechargeEmitter = function(self)
    
        self.Rotator:SetTargetSpeed(0)
    
        for _,key in self.EmitterEffects do
            key:Destroy()
        end
    
        AStructureUnit.RechargeEmitter(self)
        
        self.Rotator:SetTargetSpeed(16)
        
        for k,v in FxAmbient do
            table.insert( self.EmitterEffects, CreateAttachedEmitter( self, 'TargetBone01', self:GetArmy(), v ):ScaleEmitter(.25) )
            table.insert( self.EmitterEffects, CreateAttachedEmitter( self, 'TargetBone02', self:GetArmy(), v ):ScaleEmitter(.25) )
            table.insert( self.EmitterEffects, CreateAttachedEmitter( self, 'TargetBone03', self:GetArmy(), v ):ScaleEmitter(.25) )
            table.insert( self.EmitterEffects, CreateAttachedEmitter( self, 'TargetBone04', self:GetArmy(), v ):ScaleEmitter(.25) )
        end
    
    end,
}

TypeClass = XAB3301
local CAirUnit = import('/lua/cybranunits.lua').CConstructionUnit

local LOUDATTACHBEAMENTITY = AttachBeamEntityToEntity

local CreateCybranBuildBeams = import('/lua/EffectUtilities.lua').CreateCybranBuildBeams

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

URA0001 = Class(CAirUnit) {

    OnCreate = function(self)
    
        CAirUnit.OnCreate(self) 
        
        self.BuildArmManipulator = CreateBuilderArmController(self, 'URA0001' , 'URA0001', 0)
        self.BuildArmManipulator:SetAimingArc(-180, 180, 360, -90, 90, 360)
        self.BuildArmManipulator:SetPrecedence(5)
        
        TrashAdd( self.Trash, self.BuildArmManipulator )
        
        self.Army = self:GetArmy()
        
        self.BuildEffectsBag = TrashBag()
        
        self.DamageEffectsBag = nil
        self.EventCallbacks = {}

        self.OnBeingBuiltEffectsBag = nil
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
    
        TrashAdd( self.BuildEffectsBag, LOUDATTACHBEAMENTITY( self, 'Muzzle_03', self, 'Muzzle_01', self.Army, '/effects/emitters/build_beam_02_emit.bp') )		
        
        TrashAdd( self.BuildEffectsBag, LOUDATTACHBEAMENTITY( self, 'Muzzle_03', self, 'Muzzle_02', self.Army, '/effects/emitters/build_beam_02_emit.bp'))
        
        CreateCybranBuildBeams( self, unitBeingBuilt, {'Muzzle_03',}, self.BuildEffectsBag )
        
    end,
  
    SetParent = function(self, parent)
        self.parent = parent
    end,

    GetParent = function(self)
        return self.parent
    end,
}

TypeClass = URA0001
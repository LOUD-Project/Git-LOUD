local TShieldLandUnit = import('/lua/terranunits.lua').TShieldLandUnit

local CreateRotator = CreateRotator

UEL0308 = Class(TShieldLandUnit) {

    ShieldEffects = {
        '/effects/emitters/terran_shield_generator_mobile_01_emit.bp',
        '/effects/emitters/terran_shield_generator_mobile_02_emit.bp',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        TShieldLandUnit.OnStopBeingBuilt(self,builder,layer)
		self.ShieldEffectsBag = {}
    end,
    
    OnShieldEnabled = function(self)
        TShieldLandUnit.OnShieldEnabled(self)
        KillThread( self.DestroyManipulatorsThread )
        
        if not self.RotatorManipulator then
            self.RotatorManipulator = CreateRotator( self, 'Spinner', 'y' )
            self.Trash:Add( self.RotatorManipulator )
        end
        
        self.RotatorManipulator:SetAccel( 2.5 )
        self.RotatorManipulator:SetTargetSpeed( 60 )
        
        if not self.AnimationManipulator then
            local myBlueprint = self:GetBlueprint()
            self.AnimationManipulator = CreateAnimator(self)
            self.AnimationManipulator:PlayAnim( myBlueprint.Display.AnimationOpen )
            self.Trash:Add( self.AnimationManipulator )
        end
        
        self.AnimationManipulator:SetRate(1)
        
        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        
        local LOUDINSERT = table.insert
        local LOUDATTACHEMITTER = CreateAttachedEmitter
        local army = self:GetArmy()
        
        for _, v in self.ShieldEffects do
            LOUDINSERT( self.ShieldEffectsBag, LOUDATTACHEMITTER( self, 0, army, v ) )
        end
    end,

    OnShieldDisabled = function(self)
        TShieldLandUnit.OnShieldDisabled(self)
        KillThread( self.DestroyManipulatorsThread )
        self.DestroyManipulatorsThread = self:ForkThread( self.DestroyManipulators )
        
        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,

    DestroyManipulators = function(self)
        if self.RotatorManipulator then
            self.RotatorManipulator:SetAccel( 5 )
            self.RotatorManipulator:SetTargetSpeed( 0 )
        end
        if self.AnimationManipulator then
            self.AnimationManipulator:SetRate(-1)
            WaitFor( self.AnimationManipulator )
            self.AnimationManipulator:Destroy()
            self.AnimationManipulator = nil
        end
    end,
}

TypeClass = UEL0308

local AShieldHoverLandUnit = import('/lua/aeonunits.lua').AShieldHoverLandUnit



UAL0308 = Class(AShieldHoverLandUnit) {
    
    ShieldEffects = {
        '/effects/emitters/aeon_shield_generator_mobile_01_emit.bp',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        AShieldHoverLandUnit.OnStopBeingBuilt(self,builder,layer)
		self.ShieldEffectsBag = {}
    end,
    
    OnShieldEnabled = function(self)
        AShieldHoverLandUnit.OnShieldEnabled(self)
		
		local LOUDINSERT = table.insert
		local LOUDATTACHEMITTER = CreateAttachedEmitter
		
        if not self.Animator then
            self.Animator = CreateAnimator(self)
            self.Trash:Add(self.Animator)
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationOpen)
        end
		
        self.Animator:SetRate(1)

        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
		
        local army = self:GetArmy()
        
        for _, v in self.ShieldEffects do
            LOUDINSERT( self.ShieldEffectsBag, LOUDATTACHEMITTER( self, 0, army, v ) )
        end
    end,

    OnShieldDisabled = function(self)
        AShieldHoverLandUnit.OnShieldDisabled(self)
        if self.Animator then
            self.Animator:SetRate(-1)
        end
         
        if self.ShieldEffectsBag then
            for _, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,


}

TypeClass = UAL0308


local TShieldSeaUnit = import('/lua/terranunits.lua').TShieldSeaUnit

XES0205 = Class(TShieldSeaUnit) {

    ShieldEffects = {
        '/effects/emitters/terran_shield_generator_shipmobile_01_emit.bp',
        '/effects/emitters/terran_shield_generator_shipmobile_02_emit.bp',
    },

    OnStopBeingBuilt = function(self,builder,layer)
        TShieldSeaUnit.OnStopBeingBuilt(self,builder,layer)
		self.ShieldEffectsBag = {}
    end,

    OnShieldEnabled = function(self)
        TShieldSeaUnit.OnShieldEnabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
		
		local army = self:GetArmy()
		local LOUDINSERT = table.insert
		local CreateAttachedEmitter = CreateAttachedEmitter
		
        for k, v in self.ShieldEffects do
            LOUDINSERT( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XES0205', army, v ) )
        end
    end,

    OnShieldDisabled = function(self)
        TShieldSeaUnit.OnShieldDisabled(self)

        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,
}

TypeClass = XES0205
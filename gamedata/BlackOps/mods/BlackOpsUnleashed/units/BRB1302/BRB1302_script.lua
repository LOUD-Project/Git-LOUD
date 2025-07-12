local CEnergyCreationUnit = import('/lua/defaultunits.lua').EnergyCreationUnit

local CreateAttachedEmitter = CreateAttachedEmitter

URB1102 = Class(CEnergyCreationUnit) {

    AirEffects      = {'/effects/emitters/hydrocarbon_smoke_01_emit.bp',},
    AirEffectsBones = {'Exhaust01', 'Exhaust02', 'Exhaust03', 'Exhaust04','Exhaust05','Exhaust06','Exhaust07',},

    WaterEffects        = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp',},
    WaterEffectsBones   = {'Exhaust01', 'Exhaust02', 'Exhaust03', 'Exhaust04','Exhaust05','Exhaust06','Exhaust07',},

    OnStopBeingBuilt = function(self,builder,layer)
        CEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)
        self.EffectsBag = {}
        ChangeState(self, self.ActiveState)
    end,

    ActiveState = State {
        Main = function(self)
            local effects = {}
            local bones = {}
            local scale = .5

            if self.CacheLayer == 'Land' then
                effects = self.AirEffects
                bones = self.AirEffectsBones
                
            elseif self.CacheLayer == 'Seabed' then
                effects = self.WaterEffects
                bones = self.WaterEffectsBones
                scale = 2
            end

            for keffects, veffects in effects do
                for kbones, vbones in bones do
                    table.insert(self.EffectsBag, CreateAttachedEmitter(self,vbones,self:GetArmy(), veffects):ScaleEmitter(scale):OffsetEmitter(0,-.1,0))
                end
            end
        end,

        OnInActive = function(self)
            ChangeState(self, self.InActiveState)
        end,
    },

    InActiveState = State {
        Main = function(self)
            if self.EffectsBag then
                for keys,values in self.EffectsBag do
                    values:Destroy()
                end
                self.EffectsBag = {}
            end
        end,

        OnActive = function(self)
            ChangeState(self, self.ActiveState)
        end,
    },
}

TypeClass = URB1102
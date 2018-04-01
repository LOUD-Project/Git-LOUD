local TEnergyCreationUnit = import('/lua/terranunits.lua').TEnergyCreationUnit

local LOUDSTATE = ChangeState
local LOUDINSERT = table.insert
local LOUDATTACHEMITTER = CreateAttachedEmitter

UEB1102 = Class(TEnergyCreationUnit) {

    DestructionPartsHighToss = {'Exhaust01',},
    DestructionPartsLowToss = {'Exhaust01','Exhaust02','Exhaust03','Exhaust04','Exhaust05',},
    DestructionPartsChassisToss = {'UEB1102'},
	
    AirEffects = {'/effects/emitters/hydrocarbon_smoke_01_emit.bp',},
    AirEffectsBones = {'Exhaust01'},
	
    WaterEffects = {'/effects/emitters/underwater_idle_bubbles_01_emit.bp',},
    WaterEffectsBones = {'Exhaust01'},

    OnStopBeingBuilt = function(self,builder,layer)
	
        TEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)

        self.EffectsBag = {}
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
		
        LOUDSTATE(self, self.ActiveState)
    end,

    ActiveState = State {
	
        Main = function(self)
		
            -- Play the "activate" sound
            local myBlueprint = self:GetBlueprint()
			
            if myBlueprint.Audio.Activate then
                self:PlaySound(myBlueprint.Audio.Activate)
            end

            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(1)

            WaitFor(self.AnimManip)

            local effects = {}
            local bones = {}
            local scale = 1
			
            if self:GetCurrentLayer() == 'Land' then
			
                effects = self.AirEffects
                bones = self.AirEffectsBones
				
            elseif self:GetCurrentLayer() == 'Seabed' then
			
                effects = self.WaterEffects
                bones = self.WaterEffectsBones
                scale = 3
				
            end
            
            local army = self:GetArmy()
			local LOUDINSERT = table.insert
			local LOUDATTACHEMITTER = CreateAttachedEmitter

            for _,values in effects do
			
                for _,valuesbones in bones do
                    LOUDINSERT(self.EffectsBag, LOUDATTACHEMITTER(self,valuesbones, army, values):ScaleEmitter(scale):OffsetEmitter(0,-.1,0))
                end
				
            end
			
        end,

        OnInActive = function(self)
            LOUDSTATE(self, self.InActiveState)
        end,
    },

    InActiveState = State {
        Main = function(self)

            if self.EffectsBag then
                for _,values in self.EffectsBag do
                    values:Destroy()
                end
                self.EffectsBag = {}
            end
            self.AnimManip:SetRate(-1)

        end,

        OnActive = function(self)
            LOUDSTATE(self, self.ActiveState)
        end,
    },

}

TypeClass = UEB1102
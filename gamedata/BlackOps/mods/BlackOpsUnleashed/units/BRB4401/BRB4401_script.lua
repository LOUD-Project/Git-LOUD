local CRadarJammerUnit = import('/lua/defaultunits.lua').RadarJammerUnit

BRB4401 = Class(CRadarJammerUnit) {
    IntelEffects = {
		{
			Bones = {
				'Emitter',
			},
			Offset = {
				0,
				3,
				0,
			},
			Type = 'Jammer01',
		},
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        CRadarJammerUnit.OnStopBeingBuilt(self,builder,layer)
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
    end,
    --[[
    OnIntelDisabled = function(self)
        CRadarJammerUnit.OnIntelDisabled(self)
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
        self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationActive, false):SetRate(-1)
    end,

    OnIntelEnabled = function(self)
        CRadarJammerUnit.OnIntelEnabled(self)
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
        self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationActive, false):SetRate(1)
    end,
    ]]--
    
}

TypeClass = BRB4401
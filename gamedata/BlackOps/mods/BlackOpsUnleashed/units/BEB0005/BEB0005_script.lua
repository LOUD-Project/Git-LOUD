local TPodTowerUnit = import('/lua/terranunits.lua').TPodTowerUnit

BEB0005 = Class(TPodTowerUnit) {
    OnStopBeingBuilt = function(self,builder,layer)
        TPodTowerUnit.OnStopBeingBuilt(self,builder,layer)
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.Trash:Add(self.OpenAnim)
        end
        self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(0.4)
    end,
	
	--Make this unit invulnerable
    OnDamage = function()
    end,
	
	Parent = nil,

    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,
}

TypeClass = BEB0005
local TConstructionUnit = import('/lua/terranunits.lua').TConstructionUnit

UEA0001 = Class(TConstructionUnit) {
    Parent = nil,

    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.Pod = podName
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.Parent and not self.Parent:IsDead() then
            self.Parent:NotifyOfPodDeath(self.Pod)
            self.Parent = nil
        end
        TConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

}

TypeClass = UEA0001

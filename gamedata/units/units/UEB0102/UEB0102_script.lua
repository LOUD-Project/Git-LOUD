local TAirFactoryUnit = import('/lua/terranunits.lua').TAirFactoryUnit

local WaitFor = WaitFor

UEB0102 = Class(TAirFactoryUnit) {
    
    StartArmsMoving = function(self)
        TAirFactoryUnit.StartArmsMoving(self)

        if not self.ArmSlider then
            self.ArmSlider = CreateSlider(self, 'Arm01')
            self.Trash:Add(self.ArmSlider)
        end
        
    end,

    MovingArmsThread = function(self)
        TAirFactoryUnit.MovingArmsThread(self)
        while true do
            if not self.ArmSlider then return end
            self.ArmSlider:SetGoal(0, 6, 0)
            self.ArmSlider:SetSpeed(20)
            WaitFor(self.ArmSlider)
            self.ArmSlider:SetGoal(0, -6, 0)
            WaitFor(self.ArmSlider)
        end
    end,
    
    StopArmsMoving = function(self)
        TAirFactoryUnit.StopArmsMoving(self)
        if not self.ArmSlider then return end
        self.ArmSlider:SetGoal(0, 0, 0)
        self.ArmSlider:SetSpeed(40)
    end,


}

TypeClass = UEB0102

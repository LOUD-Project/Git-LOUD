local TSeaFactoryUnit = import('/lua/terranunits.lua').TSeaFactoryUnit

local WaitFor = WaitFor

UEB0103 = Class(TSeaFactoryUnit) {    
    StartArmsMoving = function(self)
        TSeaFactoryUnit.StartArmsMoving(self)
        if not self.ArmSlider then
            self.ArmSlider = CreateSlider(self, 'Right_Arm')
            self.Trash:Add(self.ArmSlider)
        end
        
    end,

    MovingArmsThread = function(self)
        TSeaFactoryUnit.MovingArmsThread(self)
		
		local WaitFor = WaitFor
		
        while true do
            if not self.ArmSlider then return end
            self.ArmSlider:SetGoal(0, 0, 40)
            self.ArmSlider:SetSpeed(40)
            WaitFor(self.ArmSlider)
            self.ArmSlider:SetGoal(0, 0, 0)
            WaitFor(self.ArmSlider)
        end
    end,
    
    StopArmsMoving = function(self)
        TSeaFactoryUnit.StopArmsMoving(self)
        self.ArmSlider:SetGoal(0, 0, 0)
        self.ArmSlider:SetSpeed(40)
    end,

}

TypeClass = UEB0103
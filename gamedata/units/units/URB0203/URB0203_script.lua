local CSeaFactoryUnit = import('/lua/cybranunits.lua').CSeaFactoryUnit

local WaitFor = WaitFor

URB0203 = Class(CSeaFactoryUnit) {
    
    StartArmsMoving = function(self)
        CSeaFactoryUnit.StartArmsMoving(self)
        if not self.ArmSlider1 then
            self.ArmSlider1 = CreateSlider(self, 'Right_Arm02')
            self.Trash:Add(self.ArmSlider1)
        end
        if not self.ArmSlider2 then
            self.ArmSlider2 = CreateSlider(self, 'Right_Arm03')
            self.Trash:Add(self.ArmSlider2)
        end
    end,

    MovingArmsThread = function(self)
        CSeaFactoryUnit.MovingArmsThread(self)
		local WaitFor = WaitFor
        while true do
            if not self.ArmSlider1 then return end
            if not self.ArmSlider2 then return end
            self.ArmSlider1:SetGoal(20, 0, 0)
            self.ArmSlider1:SetSpeed(40)
            self.ArmSlider2:SetGoal(-20, 0, 0)
            self.ArmSlider2:SetSpeed(40)
            WaitFor(self.ArmSlider2)
            self.ArmSlider1:SetGoal(0, 0, 0)
            self.ArmSlider1:SetSpeed(40)
            self.ArmSlider2:SetGoal(0, 0, 0)
            self.ArmSlider2:SetSpeed(40)
            WaitFor(self.ArmSlider2)
        end
    end,
    
    StopArmsMoving = function(self)
        CSeaFactoryUnit.StopArmsMoving(self)
        self.ArmSlider1:SetGoal(0, 0, 0)
        self.ArmSlider1:SetSpeed(40)
        self.ArmSlider2:SetGoal(0, 0, 0)
        self.ArmSlider2:SetSpeed(40)
    end,
}

TypeClass = URB0203

local Unit = import('/lua/sim/Unit.lua').Unit

URB5206 = Class(Unit) {

    OnCreate = function(self)
        Unit.OnCreate(self)
        ChangeState(self, self.TrackingState)
    end,
    
    TrackingState = State {
        Main = function(self)
            WaitSeconds(300)
            self:Destroy()
        end,
    },
}


TypeClass = URB5206
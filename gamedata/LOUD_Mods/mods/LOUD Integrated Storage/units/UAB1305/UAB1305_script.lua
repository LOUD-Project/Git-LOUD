local AMassFabricationUnit = import('/lua/aeonunits.lua').AMassFabricationUnit

UAB1305 = Class(AMassFabricationUnit) {

    OnStopBeingBuilt = function(self, builder, layer)
	
        AMassFabricationUnit.OnStopBeingBuilt(self, builder, layer)
        #B04 = parent, B03 = ball, B01/2 = rings
        #CreateRotator(unit, bone, axis, [goal], [speed], [accel], [goalspeed])
        local num = self:GetRandomDir()
		local CreateRotator = CreateRotator
		local Random = Random
		
#        self.RingManip1 = CreateRotator(self, 'B01', 'x', nil, 0, 15, 60)
#        self.Trash:Add(self.RingManip1)
#        self.RingManip2 = CreateRotator(self, 'B02', 'x', nil, 0, 15, -60)
#        self.Trash:Add(self.RingManip2)

        self.BallManip = CreateRotator(self, 'B03', 'y', nil, 0, 15, 55 + Random(0, 20) * num)
        self.Trash:Add(self.BallManip)
        self.ParentManip1 = CreateRotator(self, 'B04', 'z', nil, 0, 15, 55 + Random(0, 20) * num)
        self.Trash:Add(self.ParentManip1)
        self.ParentManip2 = CreateRotator(self, 'B04', 'y', nil, 0, 15, 55 + Random(0, 20) * num)
        self.Trash:Add(self.ParentManip2)
        self.ParentManip3 = CreateRotator(self, 'B04', 'x', nil, 0, 15, 55 + Random(0, 20) * num)
        self.Trash:Add(self.ParentManip3)
    end,

    OnProductionPaused = function(self)
        AMassFabricationUnit.OnProductionPaused(self)
        local num = self:GetRandomDir()
		local Random = Random

        self.BallManip:SetSpinDown(true)
        self.BallManip:SetTargetSpeed(55 + Random(0, 20) * num)
        self.ParentManip1:SetSpinDown(true)
        self.ParentManip1:SetTargetSpeed(55 + Random(0, 20) * num)
        self.ParentManip2:SetSpinDown(true)
        self.ParentManip2:SetTargetSpeed(55 + Random(0, 20) * num)
        self.ParentManip3:SetSpinDown(true)
        self.ParentManip3:SetTargetSpeed(55 + Random(0, 20) * num)
    end,
    
    OnProductionUnpaused = function(self)
        AMassFabricationUnit.OnProductionUnpaused(self)

        self.BallManip:SetSpinDown(false)
        self.ParentManip1:SetSpinDown(false)
        self.ParentManip2:SetSpinDown(false)
        self.ParentManip3:SetSpinDown(false)
    end,


    GetRandomDir = function(self)
        local num = Random(0, 2)
        if num > 1 then
            return 1
        end
        return -1
    end,
}

TypeClass = UAB1305
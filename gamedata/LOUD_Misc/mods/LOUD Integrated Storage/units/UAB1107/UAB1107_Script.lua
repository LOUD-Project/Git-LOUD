local AMassFabricationUnit = import('/lua/defaultunits.lua').MassFabricationUnit

local ChangeState = ChangeState

UAB1104 = Class(AMassFabricationUnit) {

    OnCreate = function(self)

        AMassFabricationUnit.OnCreate(self)

        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        AMassFabricationUnit.OnStopBeingBuilt(self,builder,layer)
        ChangeState(self, self.OpenState)
    end,

    OpenState = State {

        Main = function(self)

			if self.AmbientEffects then
				self.AmbientEffects:Destroy()
				self.AmbientEffects = nil
			end
			
            if not self.Open then
                self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationOpen):SetRate(1)
                WaitFor(self.AnimManip)
                
                self.Open = true
            end

            if not self.Rotator then
                self.Rotator = CreateRotator(self, 'Axis', 'z', nil, 0, 50, 0)
                self.Trash:Add(self.Rotator)
            else
                self.Rotator:SetSpinDown(false)
            end

            self.Goal = Random(75,225)
            
			self.AmbientEffects = CreateEmitterAtEntity(self, self:GetArmy(), '/effects/emitters/aeon_t1_massfab_ambient_01_emit.bp'):ScaleEmitter(1.25)
			self.Trash:Add(self.AmbientEffects)

            while not self.Dead do

                if not self.Clockwise then
                    self.Rotator:SetTargetSpeed(self.Goal)

                    self.Clockwise = true
                else
                    self.Rotator:SetTargetSpeed(-self.Goal)

                    self.Clockwise = nil
                end

                WaitFor(self.Rotator)
                
                WaitTicks(61)

                self.Rotator:SetTargetSpeed(0)
                WaitFor(self.Rotator)

                self.Rotator:SetSpeed(0)

                self.Goal = Random(75,225)
            end
        end,

        OnProductionPaused = function(self)
            AMassFabricationUnit.OnProductionPaused(self)
            ChangeState(self, self.InActiveState)
        end,
    },

    InActiveState = State {

        Main = function(self)

			if self.AmbientEffects then
				self.AmbientEffects:Destroy()
				self.AmbientEffects = nil
			end
			
            if self.Open then

                if self.Clockwise == true then
                    self.Rotator:SetSpinDown(true)
                    self.Rotator:SetTargetSpeed(self.Goal)
                else
                    self.Rotator:SetTargetSpeed(0)
                    WaitFor(self.Rotator)
                    self.Rotator:SetSpinDown(true)
                    self.Rotator:SetTargetSpeed(self.Goal)
                end

                WaitFor(self.Rotator)
            end

            if self.Open then
                self.AnimManip:SetRate(-1)
                self.Open = nil
                WaitFor(self.AnimManip)
            end
        end,

        OnProductionUnpaused = function(self)
            AMassFabricationUnit.OnProductionUnpaused(self)
            ChangeState(self, self.OpenState)
        end,
    },
}

TypeClass = UAB1104
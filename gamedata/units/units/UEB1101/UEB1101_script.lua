local TEnergyCreationUnit = import('/lua/terranunits.lua').TEnergyCreationUnit

local LOUDSTATE = ChangeState
local CreateSlider = CreateSlider
local WaitFor = WaitFor

UEB1101 = Class(TEnergyCreationUnit) {

    OnCreate = function(self)
	
        TEnergyCreationUnit.OnCreate(self)
		
		local CreateSlider = CreateSlider
		
		-- for the arms that extend away from the body
        self.Sliders = {
            Slider1 = CreateSlider(self, 'B03'),
            Slider2 = CreateSlider(self, 'B04'),
            Slider3 = CreateSlider(self, 'B05'),
            Slider4 = CreateSlider(self, 'B06'),
        }
		
        self.Spinners = {
            Spinner1 = CreateRotator(self, 'B01', 'y', nil, 0, 60, 360):SetTargetSpeed(0),
            Spinner2 = CreateRotator(self, 'B02', 'y', nil, 0, 30, 360):SetTargetSpeed(0),
        }
		
        for k, v in self.Sliders do
            self.Trash:Add(v)
        end
		
        for k, v in self.Spinners do
            self.Trash:Add(v)
        end
		
    end,

    OnStopBeingBuilt = function(self,builder,layer)
	
        TEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)
        
        LOUDSTATE(self, self.OpeningState)
    end,

    OnDestroy = function(self)
	
        TEnergyCreationUnit.OnDestroy(self)
		
        LOUDSTATE(self, self.DeadState)
		
    end,

	-- nixxing the state change when damage occurs as it's just visual bling 
--[[
    OnDamage = function(self, instigator, amount, vector, damageType)
	
        TEnergyCreationUnit.OnDamage(self, instigator, amount, vector, damageType)
		
        self.DamageSeconds = 10
		
        LOUDSTATE(self, self.ClosingState)
		
    end,
--]]

    OpeningState = State {
	
        Main = function(self)
		
            if self:GetBlueprint().Audio.Activate then
                self:PlaySound(self:GetBlueprint().Audio.Activate)
            end
			
            self.Sliders.Slider1:SetGoal(0,0,-3)
            self.Sliders.Slider1:SetSpeed(5)
            self.Sliders.Slider2:SetGoal(-3,0,0)
            self.Sliders.Slider2:SetSpeed(5)
            self.Sliders.Slider3:SetGoal(0,0,3)
            self.Sliders.Slider3:SetSpeed(5)
            self.Sliders.Slider4:SetGoal(3,0,0)
            self.Sliders.Slider4:SetSpeed(5)
			
            for k, v in self.Sliders do
                WaitFor(v)
            end
			
            for k, v in self.Spinners do
                v:SetSpinDown(false)
            end
			
            self.Spinners.Spinner1:SetTargetSpeed(90)
            self.Spinners.Spinner2:SetTargetSpeed(-45)
			
            WaitSeconds(5)
			
            LOUDSTATE(self, self.IdleOpenState)
        end,
    },

    IdleOpenState = State {
	
        Main = function(self)
		
            --self.Effect1 = CreateAttachedEmitter(self,'Exhaust01',self:GetArmy(), '/effects/emitters/economy_electricity_01_emit.bp')
            --self.Trash:Add(self.Effecct1)
			
        end,
		
    },

--[[
    ClosingState = State {
        Main = function(self)
            if self.Effect1 then
                self.Effect1:Destroy()
            end
            for k, v in self.Spinners do
                v:SetSpinDown(true)
                v:SetTargetSpeed(360)
            end
            for k,v in self.Spinners do
                WaitFor(v)
            end
            for k, v in self.Sliders do
                v:SetGoal(0,0,0)
                v:SetSpeed(20)
            end
            for k,v in self.Sliders do
                WaitFor(v)
            end
            LOUDSTATE(self, self.ClosedIdleState)
        end,

    },

    ClosedIdleState = State {
        Main = function(self)
            while self.DamageSeconds > 0 do
                WaitSeconds(1)
                self.DamageSeconds = self.DamageSeconds - 1
            end
            LOUDSTATE(self, self.OpeningState)
        end,

        OnDamage = function(self, instigator, amount, vector, damageType)
            TEnergyCreationUnit.OnDamage(self, instigator, amount, vector, damageType)
            self.DamageSeconds = 10
        end,
    },
--]]

    DeadState = State {
        Main = function(self)

        end,
    },
}

TypeClass = UEB1101
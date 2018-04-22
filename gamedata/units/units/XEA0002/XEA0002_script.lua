
local TAirUnit = import('/lua/terranunits.lua').TAirUnit
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

XEA0002 = Class(TAirUnit) {
	DestroyNoFallRandomChance = 1.1,
	
	HideBones = { 'Shell01', 'Shell02', 'Shell03', 'Shell04', },
	
	OnKilled = function(self, instigator, type, overkillRatio)
		if self.IsDying then 
			return
		end
		self.IsDying = true
		
		-- Destroy the trash pile
		self.Trash:Destroy()
		
		-- Set the parent to know it has no Satellite
		self.Parent.hasSat = false
		
		TAirUnit.OnKilled(self, instigator, type, overkillRatio)        
	end,
	
	Open = function(self)
		self:SetMaintenanceConsumptionActive()
		ChangeState(self, self.OpenState)
	end,
	
	OpenState = State() {
		Main = function(self)
			-- Perform animations
			self.OpenAnim = CreateAnimator(self)
			self.OpenAnim:PlayAnim('/units/XEA0002/xea0002_aopen01.sca')
			WaitTicks(50)
			-- Hide the shell bones
			for k,v in self.HideBones do
				self:HideBone(v, true)
			end
			-- Open the panels out
			self.OpenAnim:PlayAnim('/units/XEA0002/xea0002_aopen02.sca')
			WaitFor(self.OpenAnim)
			
			-- Add the animator to the trash pile
			self.Trash:Add(self.OpenAnim)

			-- Lifetime of the Satellite (in seconds)
			local SatLifetime = 600
			
			-- Loop whilst we exist
			while self do
				-- Wait a second
				WaitTicks(10)
				-- Reduce the SatLifetime by 1
				SatLifetime = SatLifetime - 1
				
				-- If our Lifetime hits 0, Kill the Satellite
				if SatLifetime == 0 then
					self.Kill(self)
				end
			end
		end,
	},
}

TypeClass = XEA0002

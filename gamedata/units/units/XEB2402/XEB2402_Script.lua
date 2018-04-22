local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local CreateAttachedEmitter = CreateAttachedEmitter

local WaitTicks = WaitTicks

-- The time it takes to "build" a Satellite. This shouldn't go lower than two,
-- as the last two seconds of build time are separately waited for as the Novax does some animations
local BuildSatTime = 15

XEB2402 = Class(TStructureUnit) {
	OnStopBeingBuilt = function(self)
		TStructureUnit.OnStopBeingBuilt(self)
		self:SetMaintenanceConsumptionActive()
		ChangeState( self, self.OpenState )
	end,
	
	OpenState = State() {
		
        Main = function(self)
			
			self.hasSat = false

			local bp = self:GetBlueprint()
			local location = self:GetPosition('Attachpoint01')
			local army = self:GetArmy()

			while not self.Dead do
				LOG("Looping")
				-- Check if the IntelToggle is clicked or not. If not, that means it's enabled (Confusing)
				if not self:GetScriptBit('RULEUTC_IntelToggle') then
					if self.hasSat == false then
						-- Create the animator
						self.AnimManip = CreateAnimator(self)
						-- Open the launcher gantry for construction
						self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen.sca')
						self:PlayUnitSound('MoveArms')
						
						-- Create emitters for lights whilst the build arms are moving
						self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(0.06, -0.10, 1.90))
						self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(-0.06, -0.10, 1.90))
						self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(0.08, -0.5, 1.60))
						self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(-0.04, -0.5, 1.60))
						self.Trash:Add(CreateAttachedEmitter(self,'ConstuctBeam01',army, '/effects/emitters/light_red_rotator_01_emit.bp'):ScaleEmitter( 2.00 ))
						self.Trash:Add(CreateAttachedEmitter(self,'ConstuctBeam02',army, '/effects/emitters/light_red_rotator_01_emit.bp'):ScaleEmitter( 2.00 ))
						
						-- Create the Satellite
						self.Satellite = CreateUnitHPR('XEA0002', self:GetArmy(), location[1], -10, location[3], location[1], -10, location[3])
						-- Attach the Satellite
						self.Satellite:AttachTo(self, 'Attachpoint01')
						
						-- Wait whilst the Satellite is "built"
						WaitTicks((BuildSatTime-2)*10)
						
						-- Tell the Satellite that we're its parent
						self.Satellite.Parent = self
						
						-- Play animation for the launch prep
						self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen01.sca')
						self:PlayUnitSound('LaunchSat')
						-- Wait two more seconds
						WaitTicks(20)
						-- Play the launch sound effect
						-- Create emitters for launch effects
						self.Satellite.satLaunchSmoke01 = CreateAttachedEmitter(self.Satellite,'XEA0002',army, '/effects/emitters/uef_orbital_death_laser_launch_01_emit.bp'):OffsetEmitter(0.00, 0.00, 1.00)
						self.Satellite.satLaunchSmoke02 = CreateAttachedEmitter(self.Satellite,'XEA0002',army, '/effects/emitters/uef_orbital_death_laser_launch_02_emit.bp'):OffsetEmitter(0.00, 2.00, 1.00)
						
						-- Release the Satellite
						self.Satellite:DetachFrom()
						
						-- Wait before we trigger the Satellite's opening function
						WaitTicks(10)
						-- Open our Satellite up
						self.Satellite:Open()
						-- Destroy smoke emitters on the Satellite
						self.Satellite.satLaunchSmoke01:Destroy()
						self.Satellite.satLaunchSmoke02:Destroy()
						
						-- Now our satellite is operational, set this to true so we don't repeatedly build them
						self.hasSat = true
						
						-- Run the launch animation in reverse
						self.AnimManip:SetRate(-1)
						self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen01.sca')
						-- Wait two seconds as the animation plays
						WaitTicks(20)
						-- Close up the build arms
						self.AnimManip:PlayAnim( '/units/XEB2402/XEB2402_aopen.sca' )
						self:PlayUnitSound('MoveArms')
						
						-- Add the animator as Trash
						self.Trash:Add(self.AnimManip)
						-- Clear our Trash
						self.Trash:Destroy()
					end
				else
					-- If the IntelToggle is off, we kill the Satellite if it exists and isn't dead or dying
					if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
						self.hasSat = false
						self.Satellite:Kill()
					end
				end
				-- Wait half a second then loop again to prevent the loop locking up
				WaitTicks(5)
			end
		end,
	},
	
	OnKilled = function(self, instigator, type, overkillRatio)
		if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
			self.Satellite:Kill()
		end
		
		-- Destroy all of the Trash
		self.Trash:Destroy()
		
		TStructureUnit.OnKilled(self, instigator, type, overkillRatio)
	end,
	
	OnDestroy = function(self)
		if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
			self.Satellite:Destroy()
		end
		TStructureUnit.OnDestroy(self)
	end,
	
	OnCaptured = function(self, captor)
		if self and not self:IsDead() and self.Satellite and not self.Satellite:IsDead() and captor and not captor:IsDead() and self:GetAIBrain() ~= captor:GetAIBrain() then
			self:DoUnitCallbacks('OnCaptured', captor)
			local newUnitCallbacks = {}
			if self.EventCallbacks.OnCapturedNewUnit then
				newUnitCallbacks = self.EventCallbacks.OnCapturedNewUnit
			end
			local entId = self:GetEntityId()
			local unitEnh = SimUnitEnhancements[entId]
			local captorArmyIndex = captor:GetArmy()
			local captorBrain = false
			
			self.Satellite:DoUnitCallbacks('OnCaptured', captor)
			local newSatUnitCallbacks = {}
			if self.Satellite.EventCallbacks.OnCapturedNewUnit then
				newSatUnitCallbacks = self.Satellite.EventCallbacks.OnCapturedNewUnit
			end
			local satId = self:GetEntityId()
			local satEnh = SimUnitEnhancements[satId]
			local sat = ChangeUnitArmy(self.Satellite, captorArmyIndex)
			
			local newUnit = ChangeUnitArmy(self, captorArmyIndex)
			if newUnit then
				newUnit.Satellite = sat
			end
			
			if unitEnh then
				for k,v in unitEnh do
					newUnit:CreateEnhancement(v)
				end
			end
			for k,cb in newUnitCallbacks do
				if cb then
					cb(newUnit, captor)
				end
			end
			
			if satEnh then
				for k,v in satEnh do
					sat:CreateEnhancement(v)
				end
			end
			for k,cb in newSatUnitCallbacks do
				if cb then
					cb(sat, captor)
				end
			end
		end
	end,
}

TypeClass = XEB2402

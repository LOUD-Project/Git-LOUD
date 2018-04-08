local TStructureUnit = import('/lua/terranunits.lua').TStructureUnit

local CreateAttachedEmitter = CreateAttachedEmitter
local WaitFor = WaitFor

local BuildSatTime = 15

XEB2402 = Class(TStructureUnit) {

    DeathThreadDestructionWaitTime = 8,
    
    OnStopBeingBuilt = function(self)
        TStructureUnit.OnStopBeingBuilt(self)
        ChangeState( self, self.OpenState )
		self:SetMaintenanceConsumptionActive()
    end,
    
    OpenState = State() {

        Main = function(self)
		
			while not self.Dead do
			
				WaitTicks(BuildSatTime)

				if not self:GetScriptBit('RULEUTC_IntelToggle') then
			
					local newSat = true
					local bp = self:GetBlueprint()
					
					-- Play open animations.  Currently both play after unit finished, but will change
					-- to play one while being built and one when finished        
					-- Can't use PermOpenAnimation because of the satellite
					
					-- open the launcher gantry for construction
					self.AnimManip = CreateAnimator(self)
					self.AnimManip:PlayAnim( '/units/XEB2402/XEB2402_aopen.sca' )
					self:PlayUnitSound('MoveArms')
					WaitFor( self.AnimManip )
            
					-- Attach satellite to unit, play animation, release satellite
					-- Create satellite and attach to attachpoint bone
					local location = self:GetPosition('Attachpoint01')
					local army = self:GetArmy()
			
					self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(0.06, -0.10, 1.90))
					self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(-0.06, -0.10, 1.90))
					self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(0.08, -0.5, 1.60))
					self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(-0.04, -0.5, 1.60))
					self.Trash:Add(CreateAttachedEmitter(self,'Attachpoint01',army, '/effects/emitters/structure_steam_ambient_01_emit.bp'):OffsetEmitter(0.7, -0.85, 0.35))
					self.Trash:Add(CreateAttachedEmitter(self,'Attachpoint01',army, '/effects/emitters/structure_steam_ambient_02_emit.bp'):OffsetEmitter(-0.7, -0.85, 0.35))
					self.Trash:Add(CreateAttachedEmitter(self,'ConstuctBeam01',army, '/effects/emitters/light_red_rotator_01_emit.bp'):ScaleEmitter( 2.00 ))
					self.Trash:Add(CreateAttachedEmitter(self,'ConstuctBeam02',army, '/effects/emitters/light_red_rotator_01_emit.bp'):ScaleEmitter( 2.00 ))
            
					if newSat then
						WaitSeconds(BuildSatTime)
						self.Satellite = CreateUnitHPR('XEA0002', self:GetArmy(), location[1], location[2], location[3], 0, 0, 0)
						
						self.Satellite:AttachTo(self, 'Attachpoint01')
					end
            
					-- Tell the satellite that we're its parent
					self.Satellite.Parent = self
            
					-- Play animation for the launch
					self.AnimManip:SetRate(0.5)
					self.AnimManip:PlayAnim( '/units/XEB2402/XEB2402_aopen01.sca' )
					self:PlayUnitSound('LaunchSat')
					WaitFor( self.AnimManip )
					
					self.Trash:Add(CreateAttachedEmitter(self,'XEB2402',army, '/effects/emitters/uef_orbital_death_laser_launch_01_emit.bp'):OffsetEmitter(0.00, 0.00, 1.00))
					self.Trash:Add(CreateAttachedEmitter(self,'XEB2402',army, '/effects/emitters/uef_orbital_death_laser_launch_02_emit.bp'):OffsetEmitter(0.00, 2.00, 1.00))
            
					-- Release the satellite
					if newSat then
						self.Satellite:DetachFrom()
						self.Satellite:Open()
					end
					
					WaitSeconds(5)
				
					-- destroy all the emitters and animations we added
					self.Trash:Destroy()

					self.AnimManip = CreateAnimator(self)
					
					-- run the launch animation in reverse
					self.AnimManip:SetRate(-0.5)
					self.AnimManip:PlayAnim( '/units/XEB2402/XEB2402_aopen01.sca' )
					WaitFor( self.AnimManip )
					
					WaitSeconds(4)
					
					-- close the launcher gantry
					self.AnimManip:SetRate(-0.5)
					self.AnimManip:PlayAnim( '/units/XEB2402/XEB2401_aopen.sca' )
					self.Trash:Add(self.AnimManip)
					WaitFor( self.AnimManip )
					
					-- destroy all the emitters and animations we added
					self.Trash:Destroy()
					
					self.Trash:Add(self.Satellite)
					
					-- loop here while satellite is alive
					while not self.Satellite.Dead do
						WaitTicks(40)
						if self:GetScriptBit('RULEUTC_IntelToggle') then
							self.Satellite:Destroy()
						end
					end
				
					self.Satellite = false
				end
			end
        end,
    },   
    
	
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.Satellite and not self.Satellite:IsDead() and not self.Satellite.IsDying then
            self.Satellite:Kill()
        end
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
            
            if ScenarioInfo.CampaignMode then
                captorBrain = captor:GetAIBrain()
                SetIgnoreArmyUnitCap(captorArmyIndex, true)
            end
            
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
                        
            if ScenarioInfo.CampaignMode and not captorBrain.IgnoreArmyCaps then
                SetIgnoreArmyUnitCap(captorArmyIndex, false)
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
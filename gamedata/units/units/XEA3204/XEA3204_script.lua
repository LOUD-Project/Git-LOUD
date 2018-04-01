
local TConstructionUnit = import('/lua/terranunits.lua').TConstructionUnit


XEA3204 = Class(TConstructionUnit) {

    OnCreate = function(self)
	
        TConstructionUnit.OnCreate(self)
		
        self.docked = true
        self.returning = false
		self:ForkThread(self.CheckDistanceThread)
		
    end,

    SetParent = function(self, parent, podName)
	
		LOG("*AI DEBUG XEA3204 Set Parent")
		
        self.Parent = parent
        self.PodName = podName
        self:SetCreator(parent)
		
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
	
        if self.Parent and not self.Parent:IsDead() then
		
            self.Parent:NotifyOfPodDeath(self.PodName)
            self.Parent = nil
			
        end
		
        TConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
		
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order )
	
		local parentPosition = self.Parent:GetPosition(self.Parent.PodData[self.PodName].PodAttachpoint)
		local unitposition = unitBeingBuilt:GetPosition()
		local distSq = VDist2Sq(unitposition[1], unitposition[3], parentPosition[1], parentPosition[3])
		
		if distSq <= (15 * 15) then
		
			TConstructionUnit.OnStartBuild(self, unitBeingBuilt, order )
			self.returning = false
			
		else
		
			self:OnFailedToBuild()
			
		end
		
    end,    
	
    OnStopBuild = function(self, unitBuilding)
	
        TConstructionUnit.OnStopBuild(self, unitBuilding)
		
        self.returning = true
		
    end,
	
    OnFailedToBuild = function(self)
	
        TConstructionUnit.OnFailedToBuild(self)
		
        self.returning = true
		
    end,
	
    OnMotionHorzEventChange = function( self, new, old )
	
        if self and not self.Dead then
		
            if self.Parent and not self.Parent:IsDead() then
			
                local myPosition = self:GetPosition()
                local parentPosition = self.Parent:GetPosition(self.Parent.PodData[self.PodName].PodAttachpoint)
                local distSq = VDist2Sq(myPosition[1], myPosition[3], parentPosition[1], parentPosition[3])
				
                if self.docked and distSq > 0 and distSq <= (15*15) and not self.returning then
				
                    self.docked = false
                    self.Parent:ForkThread(self.Parent.NotifyOfPodStartBuild)
					
                    #LOG("Leaving dock! " .. distSq)
					
                elseif not self.docked and distSq < 1 and self.returning then
				
                    self.docked = true
                    self.Parent:ForkThread(self.Parent.NotifyOfPodStopBuild)
					
                    #LOG("Docked again " .. distSq)
					
                elseif distSq > ( 15 * 15 ) then
				
					self.docked = false
					
					--LOG("*AI DEBUG Pod is outside radius")
					
					self:OnFailedToBuild()
					
				end

            end
			
        end
		
    end,
	
	CheckDistanceThread = function( self )

		while self.Parent and not self.Parent:IsDead() and not self.Dead do
		
			WaitTicks(10)
			
            local myPosition = self:GetPosition()
            local parentPosition = self.Parent:GetPosition()	--self.Parent.PodData[self.PodName].PodAttachpoint)
            local distSq = VDist2Sq(myPosition[1], myPosition[3], parentPosition[1], parentPosition[3])		
			
			if distSq > (17 * 17) then
			
				--LOG("*AI DEBUG Pod is beyond range")
				
				Warp( self, parentPosition )
				self.docked = false

				IssueClearCommands(self)

				self:OnFailedToBuild()

			end
    
		end
	
	end,
	
}

TypeClass = XEA3204
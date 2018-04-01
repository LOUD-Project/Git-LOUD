local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SDFThauCannon = import('/lua/seraphimweapons.lua').SDFThauCannon
local SAMElectrumMissileDefense = import('/lua/seraphimweapons.lua').SAMElectrumMissileDefense

local ForkThread = ForkThread

BSL0310 = Class(SWalkingLandUnit) {
    Weapons = {
        MainGun = Class(SDFThauCannon) {},
        AntiMissile = Class(SAMElectrumMissileDefense) {},
    },
    
    
    OnStopBeingBuilt = function(self,builder,layer)
        SWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
		self.lambdaEmitterTable = {}
		self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:ForkThread(self.ResourceThread)
    end,
    
    OnScriptBitSet = function(self, bit)
	
        SWalkingLandUnit.OnScriptBitSet(self, bit)
		
        local army =  self:GetArmy()
		
        if bit == 0 then 
			self:SetMaintenanceConsumptionActive()
			self:ForkThread(self.LambdaEmitter)
    	end
    end,
    
    OnScriptBitClear = function(self, bit)
	
        SWalkingLandUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
			self:ForkThread(self.KillLambdaEmitter)
			self:SetMaintenanceConsumptionInactive()
    	end
    end,
    
LambdaEmitter = function(self)

    -- Are we dead yet, if not then wait 0.5 second
    if not self.Dead then
	
        WaitSeconds(0.5)
		
        -- Are we dead yet, if not spawn lambdaEmitter
        if not self.Dead then

            -- Gets the platforms current orientation
            local platOrient = self:GetOrientation()
            
            -- Gets the current position of the platform in the game world
            local location = self:GetPosition('Torso')

            -- Creates lambdaEmitter over the platform with a ranomly generated Orientation
            local lambdaEmitter = CreateUnit('bsb0005', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            -- Adds the new lambdaEmitter to the parent platforms lambdaEmitter table
            table.insert (self.lambdaEmitterTable, lambdaEmitter)
            
            lambdaEmitter:AttachTo(self, 'Torso') 

            -- Sets the platform unit as the lambdaEmitter parent
            lambdaEmitter:SetParent(self, 'bsl0310')
            lambdaEmitter:SetCreator(self)  
            --lambdaEmitter clean up scripts
            self.Trash:Add(lambdaEmitter)
        end
    end 
end,

KillLambdaEmitter = function(self, instigator, type, overkillRatio)
    ### Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
    if table.getn({self.lambdaEmitterTable}) > 0 then
        for k, v in self.lambdaEmitterTable do 
            IssueClearCommands({self.lambdaEmitterTable[k]}) 
            IssueKillSelf({self.lambdaEmitterTable[k]})
        end
    end
end,
	ResourceThread = function(self) 
    	### Only respawns the drones if the parent unit is not dead 
    	#LOG('*CHECK TO SEE IF WE HAVE TO TURN OFF THE FIELD!!!')
    	if not self.Dead then
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	### Check to see if the player has enough mass / energy
        	if  energy <= 10 then 

            	###Loops to check again
            	#LOG('*TURNING OFF FIELD!!')
            	self:SetScriptBit('RULEUTC_ShieldToggle', false)
            	self:ForkThread(self.ResourceThread2)

        	else
            	### If the above conditions are not met we check again
            	self:ForkThread(self.EconomyWaitUnit)
            	
        	end
    	end    
	end,

	EconomyWaitUnit = function(self)
    	if not self.Dead then
    	WaitSeconds(2)
	    #LOG('*we have enough so keep on checking Resthread1')
        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,
	
	ResourceThread2 = function(self) 
    	### Only respawns the drones if the parent unit is not dead 
    	#LOG('*CAN WE TURN IT BACK ON YET?')
    	if not self.Dead then
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	### Check to see if the player has enough mass / energy
        	if  energy > 300 then 

            	###Loops to check again
            	#LOG('*TURNING ON FIELD!!!')
            	self:SetScriptBit('RULEUTC_ShieldToggle', true)
            	self:ForkThread(self.ResourceThread)

        	else
            	### If the above conditions are not met we kill this unit
            	self:ForkThread(self.EconomyWaitUnit2)
        	end
    	end    
	end,

	EconomyWaitUnit2 = function(self)
    	if not self.Dead then
    	WaitSeconds(2)
	    #LOG('*we dont have enough so keep on checking Resthread2!!')
        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread2)
        	end
    	end
	end,


}
TypeClass = BSL0310
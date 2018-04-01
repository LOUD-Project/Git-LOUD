
local CStructureUnit = import('/lua/cybranunits.lua').CStructureUnit
local Shield = import('/lua/shield.lua').Shield

local ForkThread = ForkThread

BRB4309 = Class(CStructureUnit) {

    OnCreate = function(self)
        CStructureUnit.OnCreate(self)
        self.ExtractionAnimManip = CreateAnimator(self)
    end,

    OnStopBeingBuilt = function(self,builder,layer)
        CStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:DisableUnitIntel('CloakField')
        self.antiteleportEmitterTable = {}
        self:ForkThread(self.ResourceThread)
    end,
    OnScriptBitSet = function(self, bit)
       	CStructureUnit.OnScriptBitSet(self, bit)
       	#local army =  self:GetArmy()
       	if bit == 0 then 
       		self:ForkThread(self.antiteleportEmitter)
        	self:SetMaintenanceConsumptionActive()
       		if(not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Shaft', 'y')
            	self.Trash:Add(self.Rotator1)
        	end
        	self.Rotator1:SetTargetSpeed(30)
        	self.Rotator1:SetAccel(30)
        end
    end,
    OnScriptBitClear = function(self, bit)
        CStructureUnit.OnScriptBitClear(self, bit)
        if bit == 0 then 
        	self:ForkThread(self.KillantiteleportEmitter)
        	self:SetMaintenanceConsumptionInactive()
        	if(not self.Rotator1) then
            	self.Rotator1 = CreateRotator(self, 'Shaft', 'y')
            	self.Trash:Add(self.Rotator1)
        	end
        	self.Rotator1:SetTargetSpeed(0)
        	self.Rotator1:SetAccel(30)
        end
    end,
    
    antiteleportEmitter = function(self)
    	### Are we dead yet, if not then wait 0.5 second
    	if not self:IsDead() then
        	WaitSeconds(0.5)
        	### Are we dead yet, if not spawn antiteleportEmitter
        	if not self:IsDead() then

            	### Gets the platforms current orientation
            	local platOrient = self:GetOrientation()
            
            	### Gets the current position of the platform in the game world
            	local location = self:GetPosition('Shaft')

            	### Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
            	local antiteleportEmitter = CreateUnit('brb0006', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            	### Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
            	table.insert (self.antiteleportEmitterTable, antiteleportEmitter)
            
            	antiteleportEmitter:AttachTo(self, 'Shaft') 

            	### Sets the platform unit as the antiteleportEmitter parent
            	antiteleportEmitter:SetParent(self, 'brb4309')
            	antiteleportEmitter:SetCreator(self)  
            	###antiteleportEmitter clean up scripts
            	self.Trash:Add(antiteleportEmitter)
        	end
    	end 
	end,


	KillantiteleportEmitter = function(self, instigator, type, overkillRatio)
    	### Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
    	if table.getn({self.antiteleportEmitterTable}) > 0 then
        	for k, v in self.antiteleportEmitterTable do 
            	IssueClearCommands({self.antiteleportEmitterTable[k]}) 
            	IssueKillSelf({self.antiteleportEmitterTable[k]})
        	end
    	end
	end,
    
    	ResourceThread = function(self) 
    	### Only respawns the drones if the parent unit is not dead 
    	#LOG('*CHECK TO SEE IF WE HAVE TO TURN OFF THE FIELD!!!')
    	if not self:IsDead() then
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
    	if not self:IsDead() then
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
    	if not self:IsDead() then
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	### Check to see if the player has enough mass / energy
        	if  energy >= 3000 then 

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
    	if not self:IsDead() then
    	WaitSeconds(2)
	    #LOG('*we dont have enough so keep on checking Resthread2!!')
        	if not self:IsDead() then
            	self:ForkThread(self.ResourceThread2)
        	end
    	end
	end,
    
}

TypeClass = BRB4309
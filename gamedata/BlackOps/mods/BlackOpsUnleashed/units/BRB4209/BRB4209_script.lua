local CStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local Shield = import('/lua/shield.lua').Shield

local ForkThread = ForkThread

BRB4209 = Class(CStructureUnit) {

    OnStopBeingBuilt = function(self,builder,layer)

        CStructureUnit.OnStopBeingBuilt(self,builder,layer)

        self:SetScriptBit('RULEUTC_ShieldToggle', true)

        self.antiteleportEmitterTable = {}
        self:ForkThread(self.ResourceThread)
    end,

    OnScriptBitSet = function(self, bit)

       	CStructureUnit.OnScriptBitSet(self, bit)

       	if bit == 0 then 
       		self:ForkThread(self.antiteleportEmitter)
        	self:SetMaintenanceConsumptionActive()
        end
    end,
    
    OnScriptBitClear = function(self, bit)

        CStructureUnit.OnScriptBitClear(self, bit)
        
        if bit == 0 then 
        	self:ForkThread(self.KillantiteleportEmitter)
        	self:SetMaintenanceConsumptionInactive()
        end
    end,
    
    antiteleportEmitter = function(self)

    	if not self.Dead then

        	WaitSeconds(0.5)

        	if not self.Dead then

            	local platOrient = self:GetOrientation()

            	local location = self:GetPosition('Shaft')

            	local antiteleportEmitter = CreateUnit('beb0004', self.Army, location[1], location[2]+1, location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            	table.insert (self.antiteleportEmitterTable, antiteleportEmitter)
            
            	antiteleportEmitter:AttachTo(self, 'Shaft') 

            	antiteleportEmitter:SetParent(self, 'brb4209')
            	antiteleportEmitter:SetCreator(self)  

            	self.Trash:Add(antiteleportEmitter)
        	end
    	end 
	end,


	KillantiteleportEmitter = function(self, instigator, type, overkillRatio)

    	if table.getn({self.antiteleportEmitterTable}) > 0 then

        	for k, v in self.antiteleportEmitterTable do 
            	IssueClearCommands({self.antiteleportEmitterTable[k]}) 
            	IssueKillSelf({self.antiteleportEmitterTable[k]})
        	end
            
    	end
	end,
    
   	ResourceThread = function(self) 

    	if not self.Dead then

        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy <= 10 then 

            	self:SetScriptBit('RULEUTC_ShieldToggle', false)

            	self:ForkThread(self.ResourceThread2)

        	else

            	self:ForkThread(self.EconomyWaitUnit)
            	
        	end
    	end    
	end,

	EconomyWaitUnit = function(self)
    
    	if not self.Dead then

            WaitSeconds(2)

        	if not self.Dead then
            	self:ForkThread(self.ResourceThread)
        	end
            
    	end
	end,
	
	ResourceThread2 = function(self) 

    	if not self.Dead then

        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy >= 3000 then 

            	self:SetScriptBit('RULEUTC_ShieldToggle', true)
            	self:ForkThread(self.ResourceThread)

        	else
            	self:ForkThread(self.EconomyWaitUnit2)
        	end
    	end    
	end,

	EconomyWaitUnit2 = function(self)

    	if not self.Dead then

            WaitSeconds(2)

        	if not self.Dead then
            	self:ForkThread(self.ResourceThread2)
        	end
    	end
	end,
    
}

TypeClass = BRB4209
local AStructureUnit = import('/lua/aeonunits.lua').AStructureUnit

local LOUDINSERT = table.insert
local CreateRotator = CreateRotator
local ForkThread = ForkThread

BAB4209 = Class(AStructureUnit) {

	AntiTeleportEffects = {
        '/effects/emitters/aeon_gate_02_emit.bp',
        '/effects/emitters/aeon_gate_03_emit.bp',
    },
    AmbientEffects = {
        '/effects/emitters/aeon_shield_generator_t3_04_emit.bp',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        AStructureUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:DisableUnitIntel('CloakField')
        self.AmbientEffectsBag = {}
        self.antiteleportEmitterTable = {}
        self:ForkThread(self.ResourceThread)
        
        self.Trash:Add(CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)))
        
    end,
    
    OnScriptBitSet = function(self, bit)
	
        AStructureUnit.OnScriptBitSet(self, bit)

        if bit == 0 then 
        	self:ForkThread(self.antiteleportEmitter)
        	self:ForkThread(self.AntiteleportEffects)
        	self:SetMaintenanceConsumptionActive()
		end
	end,
	
	AntiteleportEffects = function(self)
        if self.AmbientEffectsBag then
            for k, v in self.AmbientEffectsBag do
                v:Destroy()
            end
		    self.AmbientEffectsBag = {}
		end
        for k, v in self.AmbientEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'BAB4209', self:GetArmy(), v ):ScaleEmitter(0.4) )
        end
    end,
    
	OnScriptBitClear = function(self, bit)
	
        AStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
        	self:ForkThread(self.KillantiteleportEmitter)
        	self:SetMaintenanceConsumptionInactive()
			if self.AmbientEffectsBag then
            	for k, v in self.AmbientEffectsBag do
                	v:Destroy()
            	end
		    	self.AmbientEffectsBag = {}
			end
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
            	local location = self:GetPosition('BAB4209')

            	### Creates our antiteleportEmitter over the platform with a ranomly generated Orientation
            	local antiteleportEmitter = CreateUnit('bab0004', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            	### Adds the newly created antiteleportEmitter to the parent platforms antiteleportEmitter table
            	LOUDINSERT (self.antiteleportEmitterTable, antiteleportEmitter)

            	### Sets the platform unit as the antiteleportEmitter parent
            	antiteleportEmitter:SetParent(self, 'bab4209')
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

TypeClass = BAB4209
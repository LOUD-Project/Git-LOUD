local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local LOUDINSERT = table.insert
local CreateRotator = CreateRotator
local CreateAttachedEmitter = CreateAttachedEmitter
local ForkThread = ForkThread

BAB4309 = Class(AStructureUnit) {

	AntiTeleportEffects = {'/effects/emitters/aeon_gate_02_emit.bp','/effects/emitters/aeon_gate_03_emit.bp'},

    AmbientEffects = {'/effects/emitters/aeon_shield_generator_t3_04_emit.bp'},
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        AStructureUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetScriptBit('RULEUTC_ShieldToggle', true)
        self:DisableUnitIntel('CloakField')
        self.AntiTeleportEffectsBag = {}
        self.AmbientEffectsBag = {}
        self.antiteleportEmitterTable = {}
		
        self:ForkThread(self.ResourceThread)
        
        self.Trash:Add(CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)))
        
        self.Trash:Add(CreateRotator(self, 'Sphere01', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere01', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere01', 'z', nil, 0, 40, 120 + Random(0, 20)))
        
        self.Trash:Add(CreateRotator(self, 'Sphere02', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere02', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere02', 'z', nil, 0, 40, 120 + Random(0, 20)))
        
        self.Trash:Add(CreateRotator(self, 'Sphere03', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere03', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere03', 'z', nil, 0, 40, 120 + Random(0, 20)))
       
        self.Trash:Add(CreateRotator(self, 'Sphere04', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere04', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere04', 'z', nil, 0, 40, 120 + Random(0, 20)))
        
        self.Trash:Add(CreateRotator(self, 'Sphere05', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere05', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere05', 'z', nil, 0, 40, 120 + Random(0, 20)))
        
        self.Trash:Add(CreateRotator(self, 'Sphere06', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere06', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere06', 'z', nil, 0, 40, 120 + Random(0, 20)))
        
        self.Trash:Add(CreateRotator(self, 'Sphere07', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere07', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere07', 'z', nil, 0, 40, 120 + Random(0, 20)))
        
        self.Trash:Add(CreateRotator(self, 'Sphere08', 'x', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere08', 'y', nil, 0, 40, 120 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere08', 'z', nil, 0, 40, 120 + Random(0, 20)))
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
	
		if self.AntiTeleportEffectsBag then
           	for k, v in self.AntiTeleportEffectsBag do
               	v:Destroy()
           	end
	    	self.AntiTeleportEffectsBag = {}
		end
        
        local army = self.Army
        
        for k, v in self.AntiTeleportEffects do
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect01', army, v ):ScaleEmitter(0.3) )
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect02', army, v ):ScaleEmitter(0.3) )
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect03', army, v ):ScaleEmitter(0.3) )
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect04', army, v ):ScaleEmitter(0.3) )
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect05', army, v ):ScaleEmitter(0.3) )
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect06', army, v ):ScaleEmitter(0.3) )
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect07', army, v ):ScaleEmitter(0.3) )
            LOUDINSERT( self.AntiTeleportEffectsBag, CreateAttachedEmitter( self, 'Effect08', army, v ):ScaleEmitter(0.3) )
        end
		
        if self.AmbientEffectsBag then
            for k, v in self.AmbientEffectsBag do
                v:Destroy()
            end
		    self.AmbientEffectsBag = {}
		end
		
        for k, v in self.AmbientEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'XAB4309', army, v ):ScaleEmitter(0.4) )
        end
    end,
    
	OnScriptBitClear = function(self, bit)
	
        AStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
		
        	self:ForkThread(self.KillantiteleportEmitter)
        	self:SetMaintenanceConsumptionInactive()
			
        	if self.AntiTeleportEffectsBag then
            	for k, v in self.AntiTeleportEffectsBag do
                	v:Destroy()
            	end
		    	self.AntiTeleportEffectsBag = {}
			end
			
			if self.AmbientEffectsBag then
            	for k, v in self.AmbientEffectsBag do
                	v:Destroy()
            	end
		    	self.AmbientEffectsBag = {}
			end
		end
	end,

    
	antiteleportEmitter = function(self)

    	if not self.Dead then
		
        	WaitSeconds(0.5)

        	if not self.Dead then

            	local platOrient = self:GetOrientation()

            	local location = self:GetPosition('XAB4309')

                -- create the antiteleport entity using the standardized (72 range) blueprint
            	local antiteleportEmitter = CreateUnit('beb0003', self:GetArmy(), location[1], location[2]+1, location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Land') 

            	LOUDINSERT (self.antiteleportEmitterTable, antiteleportEmitter)

            	antiteleportEmitter:SetParent(self, 'bab4309')
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

TypeClass = BAB4309
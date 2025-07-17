local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local LOUDINSERT = table.insert
local CreateRotator = CreateRotator
local CreateAttachedEmitter = CreateAttachedEmitter
local ForkThread = ForkThread

BAB4309 = Class(AStructureUnit) {

    AmbientEffects = {'/effects/emitters/aeon_shield_generator_t3_04_emit.bp'},
    ShieldEffects = {'/effects/emitters/terran_shield_generator_t2_01_emit.bp','/effects/emitters/terran_shield_generator_t2_02_emit.bp'},
    
    OnStopBeingBuilt = function(self,builder,layer)
	
        AStructureUnit.OnStopBeingBuilt(self,builder,layer)
		
        self:SetScriptBit('RULEUTC_ShieldToggle', true)

        self.AmbientEffectsBag = {}
		
        self:ForkThread(self.ResourceThread)

    end,
	
	AntiteleportEffects = function(self)

       	for k, v in self.AmbientEffectsBag do
           	v:Destroy()
            self.AmbientEffectsBag[k] = nil
       	end

        local army = self.Army
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)))        

        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere01', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere01', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere01', 'z', nil, 0, 40, 80 + Random(0, 20)))
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere02', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere02', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere02', 'z', nil, 0, 40, 80 + Random(0, 20)))
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere03', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere03', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere03', 'z', nil, 0, 40, 80 + Random(0, 20)))
       
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere04', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere04', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere04', 'z', nil, 0, 40, 80 + Random(0, 20)))
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere05', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere05', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere05', 'z', nil, 0, 40, 80 + Random(0, 20)))
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere06', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere06', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere06', 'z', nil, 0, 40, 80 + Random(0, 20)))
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere07', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere07', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere07', 'z', nil, 0, 40, 80 + Random(0, 20)))
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere08', 'x', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere08', 'y', nil, 0, 40, 80 + Random(0, 20)))
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere08', 'z', nil, 0, 40, 80 + Random(0, 20)))
        
        for k, v in self.AmbientEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter(self,'XAB4309',army,v):ScaleEmitter(0.32) )
        end
	
        for k, v in self.ShieldEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect01', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect02', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect03', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect04', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect05', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect06', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect07', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Effect08', army, v ):ScaleEmitter(0.15):OffsetEmitter(0, 0.05, -0.45) )
        end

    end,

    OnScriptBitSet = function(self, bit)
	
        AStructureUnit.OnScriptBitSet(self, bit)

        if bit == 0 then

        	self:ForkThread(self.AntiteleportEffects)
			
        	self:SetMaintenanceConsumptionActive()
		end
	end,

	OnScriptBitClear = function(self, bit)
	
        AStructureUnit.OnScriptBitClear(self, bit)
		
        if bit == 0 then 
		
        	self:SetMaintenanceConsumptionInactive()

           	for k, v in self.AmbientEffectsBag do
               	v:Destroy()
                self.AmbientEffectsBag[k] = nil                    
			end
		end
	end,
	
    OnKilled = function(self, instigator, type, overkillRatio)

      	for k, v in self.AmbientEffectsBag do
           	v:Destroy()
		end
        
        self.AmbientEffectsBag = nil

        AStructureUnit.OnKilled(self, instigator, type, overkillRatio)

    end,

    ResourceThread = function(self) 

    	if not self.Dead then
		
        	local energy = self:GetAIBrain():GetEconomyStored('Energy')

        	if  energy <= 700 then 

            	self:SetScriptBit('RULEUTC_ShieldToggle', false)

                self:RemoveToggleCap('RULEUTC_ShieldToggle')

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

                self:AddToggleCap('RULEUTC_ShieldToggle')

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
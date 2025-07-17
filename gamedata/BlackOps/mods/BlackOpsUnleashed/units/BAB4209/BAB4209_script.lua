local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local LOUDINSERT = table.insert
local CreateRotator = CreateRotator
local ForkThread = ForkThread

local TrashAdd = TrashBag.Add

BAB4209 = Class(AStructureUnit) {

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
        
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)) )
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)) )
        LOUDINSERT( self.AmbientEffectsBag, CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)) )
        
        for k, v in self.AmbientEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter(self,'BAB4209',army,v):ScaleEmitter(0.24) )
        end
		
        for k, v in self.ShieldEffects do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot01', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot02', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot03', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot04', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot05', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot06', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot07', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Pivot08', army, v ):ScaleEmitter(0.1):OffsetEmitter(0, 0.7, 0) )
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

        	if  energy <= 350 then 

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

TypeClass = BAB4209
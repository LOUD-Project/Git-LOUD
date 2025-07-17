local SStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local LOUDINSERT = table.insert

BSB4209 = Class(SStructureUnit) {

AntiTeleport = {'/effects/emitters/op_seraphim_quantum_jammer_tower_emit.bp'},
    
    OnStopBeingBuilt = function(self,builder,layer)

    	SStructureUnit.OnStopBeingBuilt(self,builder,layer)

       	self.Rotator1 = CreateRotator( self, 'Array01', 'y', nil, 0, 15, 120 )
        self.Trash:Add(self.Rotator1)
        self.Rotator1:SetAccel(60)
        
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

        for k, v in self.AntiTeleport do
            LOUDINSERT( self.AmbientEffectsBag, CreateAttachedEmitter( self, 'Light01', army, v ):ScaleEmitter(0.22) )
        end
    end,

    OnScriptBitSet = function(self, bit)

        SStructureUnit.OnScriptBitSet(self, bit)

        if bit == 0 then

            self:ForkThread(self.AntiteleportEffects)

            self:SetMaintenanceConsumptionActive()
            
        	self.Rotator1:SetTargetSpeed(-120)
        end
    end,
    
    OnScriptBitClear = function(self, bit)

        SStructureUnit.OnScriptBitClear(self, bit)

        if bit == 0 then 

            self:SetMaintenanceConsumptionInactive()

        	self.Rotator1:SetTargetSpeed(0)

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

        SStructureUnit.OnKilled(self, instigator, type, overkillRatio)

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

TypeClass = BSB4209
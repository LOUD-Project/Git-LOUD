local SLandUnit = import('/lua/defaultunits.lua').MobileUnit

local SLaanseMissileWeapon = import('/lua/seraphimweapons.lua').SLaanseMissileWeapon

local ForkThread = ForkThread
local WaitTicks = coroutine.yield


BSL0004 = Class(SLandUnit) {
    Weapons = {
        MissileRack = Class(SLaanseMissileWeapon) {
		
            OnLostTarget = function(self)
                self:ForkThread( self.LostTargetThread )
            end,
            
            RackSalvoFiringState = State(SLaanseMissileWeapon.RackSalvoFiringState) {
                OnLostTarget = function(self)
                    self:ForkThread( self.LostTargetThread )
                end,            
            },            

            LostTargetThread = function(self)
			
                while not self.unit:IsDead() and self.unit:IsUnitState('Busy') do
                    WaitTicks(12)
                end
                
                if self.unit:IsDead() then
                    return
                end
                
                local bp = __blueprints[self.BlueprintID]

                if bp.WeaponUnpacks then
                    ChangeState(self, self.WeaponPackingState)
                else
                    ChangeState(self, self.IdleState)
                end
            end,
        },
    },


    OnStopBeingBuilt = function(self, builder, layer)
	
	    SLandUnit.OnStopBeingBuilt(self,builder,layer)
		
        if not self.Dead then
            self:ForkThread(self.ResourceThread)
            self:SetMaintenanceConsumptionActive()
            self:SetVeterancy(5)
			self.Brain = self:GetAIBrain()
        end
    end,
    
    
    OnKilled = function(self, instigator, type, overkillRatio)

        self:SetWeaponEnabledByLabel('MissileRack', false)
        IssueClearCommands(self)

        SLandUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    

    ResourceThread = function(self) 
	
       	if not self.Dead then
        	local energy = self.Brain:GetEconomyStored('Energy')

        	if  energy <= 10 then 
            	self:ForkThread(self.KillFactory)
        	else
            	self:ForkThread(self.EconomyWaitUnit)
        	end
    	end    
	end,

	EconomyWaitUnit = function(self)
	
    	if not self.Dead then
		
			WaitTicks(50)

        	if not self.Dead then
            	self:ForkThread(self.ResourceThread)
        	end
    	end
	end,
	
	KillFactory = function(self)
    	self:Kill()
	end,


}
TypeClass = BSL0004
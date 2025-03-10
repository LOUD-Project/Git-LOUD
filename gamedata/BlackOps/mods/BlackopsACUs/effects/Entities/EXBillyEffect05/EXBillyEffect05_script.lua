
local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')

EXBillyEffect05 = Class(NullShell) {
    
    OnCreate = function(self)
		NullShell.OnCreate(self)
		self:ForkThread(self.EffectThread)
    end,
    
    EffectThread = function(self)
		local army = self:GetArmy()
		
		for k, v in EffectTemplate.TNukeBaseEffects02 do
			CreateEmitterOnEntity(self, army, v ):ScaleEmitter(0.5)-- Exavier Modified Scale 
		end	
    end,      
}

TypeClass = EXBillyEffect05


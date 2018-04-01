#****************************************************************************
#**
#**  File     :  /effects/Entities/EXBillyEffect03/EXBillyEffect03_script.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  Nuclear explosion script
#**
#**  Copyright © 2005,2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')

EXBillyEffect03 = Class(NullShell) {
    
    OnCreate = function(self)
		NullShell.OnCreate(self)
		self:ForkThread(self.EffectThread)
    end,
    
    EffectThread = function(self)
		local army = self:GetArmy()
		for k, v in EffectTemplate.TNukeHeadEffects03 do
			CreateAttachedEmitter(self, -1, army, v ):ScaleEmitter(0.5)-- Exavier Modified Scale 
		end			
	
		WaitSeconds(6)
		for k, v in EffectTemplate.TNukeHeadEffects02 do
			CreateAttachedEmitter(self, -1, army, v ):ScaleEmitter(0.5)-- Exavier Modified Scale 
		end	
    end,      
}

TypeClass = EXBillyEffect03


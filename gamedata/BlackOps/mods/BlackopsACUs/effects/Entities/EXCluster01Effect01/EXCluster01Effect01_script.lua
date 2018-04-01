#****************************************************************************
#**
#**  File     :  /effects/Entities/EXCluster01Effect011/EXCluster01Effect01_script.lua
#**  Author(s):  Gordon Duclos
#**
#**  Summary  :  Nuclear explosion script
#**
#**  Copyright © 2005,2006 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell

EXCluster01Effect01 = Class(NullShell) {
    
    OnCreate = function(self)
		NullShell.OnCreate(self)
		self:ForkThread(self.EffectThread)
    end,
    
    EffectThread = function(self)
		local scale = self:GetBlueprint().Display.UniformScale
		local scaleChange = 0.30 * scale
		
		self:SetScaleVelocity(scaleChange,scaleChange,scaleChange)
		self:SetVelocity(0,0.0078125,0)-- Exavier Modified Velocity
		
		WaitSeconds(4)
		scaleChange = -0.01 * scale
		self:SetScaleVelocity(scaleChange,12*scaleChange,scaleChange)
		self:SetVelocity(0,0.09375,0)-- Exavier Modified Velocity
		self:SetBallisticAcceleration(-0.015625)-- Exavier Modified Velocity
		
		WaitSeconds(5)
		scaleChange = -0.1 * scale		
		self:SetScaleVelocity(scaleChange,scaleChange,scaleChange)	

    end,      
}

TypeClass = EXCluster01Effect01


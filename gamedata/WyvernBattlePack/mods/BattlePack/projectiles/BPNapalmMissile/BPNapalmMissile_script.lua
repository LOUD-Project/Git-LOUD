#****************************************************************************
#**
#**  File     : 
#**  Author(s):
#**
#**  Summary  :
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local StingerMissile = import('/mods/BattlePack/lua/BattlePackprojectiles.lua').NapalmMissile
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
BPNapalmMissile = Class(StingerMissile) {
    OnImpact = function(self, TargetType, targetEntity)
		if TargetType != 'Terrain' then 
			local rotation = RandomFloat(0,2*math.pi)
			local size = RandomFloat(3.75,5.0)
	        
			CreateDecal(self:GetPosition(), rotation, 'scorch_001_albedo', '', 'Albedo', size, size, 150, 15, self:GetArmy())
		end	 
		StingerMissile.OnImpact( self, TargetType, targetEntity )
    end,
}

TypeClass = BPNapalmMissile

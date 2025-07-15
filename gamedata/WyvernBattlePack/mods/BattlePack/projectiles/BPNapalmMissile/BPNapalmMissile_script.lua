local Missile = import('/mods/BattlePack/lua/BattlePackprojectiles.lua').NapalmMissile

local RandomFloat = import('/lua/Utilities.lua').GetRandomFloat

NapalmMissile = Class(Missile) {

    OnImpact = function(self, TargetType, targetEntity)

		if TargetType != 'Terrain' then 

			local rotation = RandomFloat(0,6.28)
	        
			CreateDecal(self:GetPosition(), rotation, 'scorch_001_albedo', '', 'Albedo', 2.5, 2.5, 150, 15, self:GetArmy())
		end	 

		Missile.OnImpact( self, TargetType, targetEntity )
    end,
}

TypeClass = NapalmMissile
